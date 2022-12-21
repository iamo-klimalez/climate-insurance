



climateinsurance <- function(year, index, yield, crop_price = 1, strike_quantile = 0.3){

  #install required package
  if(!require(tidyr)){
    install.packages("tidyr")}
  library(tidyr)

  if(!require(dplyr)){
    install.packages("dplyr")}
  library(dplyr)

  if(!require(quantreg)){
    install.packages("quantreg")}
  library(quantreg)

  if(!require(SpatialVx)){
    install.packages("SpatialVx")}
  library(SpatialVx)

  if(!require(ggplot2)){
    install.packages("ggplot2")}
  library(ggplot2)

  if(!require(reshape2)){
    install.packages("reshape2")}
  library(reshape2)

  if(!require(plotly)){
    install.packages("plotly")}
  library(plotly)

  if(!require(tidyverse)){
    install.packages("tidyverse")}
  library(tidyverse)

  if(!require(tidymodels)){
    install.packages("tidymodels")}
  library(tidymodels)


  year  <- data.frame(c(year))
  index <- data.frame(c(index))
  yield <- data.frame(c(yield))

  #data frame of selected data
  data_selected <- data.frame(c(year, index, yield))
  names(data_selected) <- c("year", "index", "yield")

  #dropping rows with NA
  calc_table <- tidyr::drop_na(data_selected)

  #calculation of quantile value
  strike_level <- quantile(calc_table$index, strike_quantile)

  #quatile regression below given tau
  quantile_regression <- quantreg::rq(calc_table$yield ~ calc_table$index, tau = strike_quantile)
  quan_inter <- quantile_regression$coef[1]
  quan_coef <- quantile_regression$coef[2]


  #calculation of index shortage
  calc_table$index_shortage <- strike_level - calc_table$index
  #setting NA for below 0
  calc_table$index_shortage[calc_table$index_shortage < 0] <- 0

  #calculation of yield shortage
  quan_yield <- quantile(calc_table$yield, strike_quantile)
  calc_table$yield_shortage <- quan_yield - calc_table$yield
  calc_table$revenue_losses <- calc_table$yield_shortage * crop_price

  #setting NA for below 0
  calc_table$yield_shortage[calc_table$yield_shortage < 0] <- 0
  calc_table$revenue_losses[calc_table$revenue_losses < 0] <- 0

  #calculation of payout
  qreg_payout <- predict(quantile_regression, data.frame(calc_table$index))
  quan_payout <- quantile(qreg_payout, strike_quantile)
  calc_table$payout <- (quan_payout - qreg_payout) * crop_price

  #setting 0 for NA
  calc_table$payout[calc_table$payout < 0] <- 0

  #premium calculation
  calc_table$premium <- mean(calc_table$payout)

  #calculation of revenue with no insurance
  calc_table$non_insured_revenue <- calc_table$yield * crop_price

  #calculation of revenue with insurance
  calc_table$insured_revenue <- calc_table$yield * crop_price + calc_table$payout - calc_table$premium

  #calculation of hedging effectiveness for insured yield
  calc_table$he_insurance <- (mean(calc_table$yield) * crop_price - calc_table$insured_revenue)
  calc_table$he_insurance[calc_table$he_insurance < 0] <- 0
  calc_table$he_insurance <- calc_table$he_insurance^2

  #calculation of hedging effectiveness for non-insured yield
  calc_table$he_noinsurance <- (mean(calc_table$yield) * crop_price - calc_table$non_insured_revenue)
  calc_table$he_noinsurance[calc_table$he_noinsurance < 0] <- 0
  calc_table$he_noinsurance <- calc_table$he_noinsurance^2

  calc_table <- calc_table %>% mutate_if(is.numeric, round, digits=4)

  #relative hedging effectiveness
  relativeHE <- 1 - (mean(calc_table$he_insurance) / mean(calc_table$he_noinsurance))


  #making matrix of yield and index shortages
  matrix_index = matrix(data = calc_table$index_shortage, nrow = 1)
  matrix_yield = matrix(data = calc_table$yield_shortage, nrow = 1)

  bias          <- vxstats(matrix_yield, matrix_index)$bias
  ts            <- vxstats(matrix_yield, matrix_index)$ts
  pod           <- vxstats(matrix_yield, matrix_index)$pod
  far           <- vxstats(matrix_yield, matrix_index)$far
  correlation   <- cor(calc_table$index, calc_table$yield)

  list_results <- list("quantile_for_strike" = strike_quantile,
                       "strike_level" = strike_level[[1]],
                       "number_of_years" = nrow(calc_table),
                       "number_of_losses" = nrow(calc_table[calc_table$revenue_losses>0, ]),
                       "number_of_payouts" = nrow(calc_table[calc_table$payout>0, ]),
                       "total_losses"= sum(calc_table$revenue_losses),
                       "total_payouts" = sum(calc_table$payout),
                       "insurance_premium" = mean(calc_table$payout),
                       "ts" = ts,
                       "pod" = pod,
                       "far"= far,
                       "correlation"=correlation,
                       "rHE"=relativeHE)



  # Data preparation for plotly
  y <- calc_table$yield
  x <- calc_table$index

  lm_model <- linear_reg() %>%
    set_engine('lm') %>%
    set_mode('regression') %>%
    fit(yield ~ index, data = calc_table)

  xdf <-data.frame(x)
  colnames(xdf) <- c('index')

  ydf <- lm_model %>% predict(xdf)
  colnames(ydf) <- c('yield')

  xy = data.frame(xdf, ydf)



  # Scatter plot
  figure_point <- plot_ly(calc_table, x = ~yield, y = ~index, type = 'scatter', alpha = 0.65, mode = 'markers', name = 'Yield vs Index')
  figure_point <- figure_point %>% add_trace(data = xy, x = ~yield, y = ~index, name = 'Regression Fit', mode = 'lines', alpha = 1)
  figure_point <- figure_point %>% layout(         xaxis = list(
    title = "Crop yield",
    tickfont = list(
      size = 14,
      color = 'rgb(107, 107, 107)')),
    yaxis = list(
      title = 'Index',
      titlefont = list(
        size = 14,
        color = 'rgb(107, 107, 107)'),
      tickfont = list(
        size = 14,
        color = 'rgb(107, 107, 107)')))



  # Barchart
  figure_bar <- plot_ly(calc_table, x = ~year, y = ~revenue_losses, type = 'bar', name = 'Revenue losses',
                        marker = list(color = 'rgb(245, 167, 108)'))
  figure_bar <- figure_bar %>% add_trace(y = ~payout, name = 'Insurance payout', marker = list(color = 'rgb(5, 128, 50)'))
  figure_bar <- figure_bar %>% layout(title = 'Crop yield VS Index | Revenue losses and insurance payments',
                                      xaxis = list(
                                        title = "Year",
                                        tickfont = list(
                                          size = 14,
                                          color = 'rgb(107, 107, 107)')),
                                      yaxis = list(
                                        title = 'Revenue loss and insurance payout',
                                        titlefont = list(
                                          size = 14,
                                          color = 'rgb(107, 107, 107)'),
                                        tickfont = list(
                                          size = 14,
                                          color = 'rgb(107, 107, 107)')),
                                      legend = list(x = 0, y = 1, bgcolor = 'rgba(255, 255, 255, 0)', bordercolor = 'rgba(255, 255, 255, 0)'),
                                      barmode = 'group', bargap = 0.15)


  figure <- subplot(figure_point, figure_bar, titleY = TRUE, titleX = TRUE, margin = 0.1 )


  # Printing results
  print(calc_table)
  print(figure)
  print(quantile_regression)
  print(list_results)


}




