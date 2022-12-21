

<!-- README.md is generated from README.Rmd. Please edit that file -->

# Climate Insurance <img src="man/figures/logo.png" align="right"/>


"Climate Insurance" package was developed for interested parties to design index-based climate insurance and analyze their climate risk reduction  potential.  The package requires the user to enter a period, crop yield and index information. Data can be entered in any delineation (eg. space, comma). Consequently, the package designs index-based climate insurance products based on entered data and calculates descriptive statistics, and conducts performance analysis.

#### Description of performance indicators:

-   Threat score (aka, critical success index) measures the fraction of yield loss events that were correctly predicted, given by hits/(hits + misses + false alarms)
-   Probability of detection (aka, hit rate) measures the probability of an index to detect yield loss events. It is given by hits/(hits + misses).
-   False alarm ratio indicates the probability of a yield loss event being detected by mistake. It is given by (false alarms)/(hits + false alarms).
-   Pearson’s Correlation Coefficient (PC) measures the linear correlation between index and crop yield
-   Hedging effectiveness is the change of expected shortfall of the revenue by the use of an index-based insurance contract. Basically, relative hedging effectiveness it compares the downside risk measure semi-variance of the revenue of uninsured crop yields with insured. Higher relative hedging effectiveness corresponds to lower basis risk and higher risk-reducing effectiveness of the insurance contract. The details about the method can be found in the following publication, Kolle et al. (2021).
-   Preference of moderate risk-averse farmers for choosing being insured or uninsured have been calculated the based on expected utility model following the publication by Bucheli et al. (2021).

Current pakcage has been developed for scientific purposes within the project “KlimALEZ – Increasing climate resilience via agricultural insurance – Innovation transfer for sustainable rural development in Central Asia” implemented by Leibniz Institute of Agricultural Development in Transition Economies (IAMO) and funded by German Federal Ministry of Education and Research (BMBF), Germany.

## Installation

You can install the package using the "devtools":

``` r
# install.packages("devtools")
devtools::install_github("iamo-klimalez/climate-insurance")
```



## Citing the package

If you use metR in your research, please consider citing it. You can get
citation information with

``` r
citation("climateinsurance")
#> 
#> To cite climateinsurance in publications use:
#> 
#> 
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {climateinsurance: Design and performance analysis of index-based climate insurances},
#>     author = {Sarvarbek Eltazarov, Ihtiyor Bobojonoc, Lena Kuhn, Thomas Glauben},
#>     year = {2022},
#>     note = {R package version 0.1},
#>     url = {https://github.com/iamo-klimalez/climate-insurance},
#>   }
```

## Examples

In this example we easily perform Principal Components Decomposition
(EOF) on monthly geopotential height, then compute the geostrophic wind
associated with this field and plot the field with filled contours and
the wind with streamlines.

``` r
library(climateinsurance)

# List od input data
year <- c(1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015)
yield <- c(0.69, 1.62, 1.04, 1.11, 1.1, 1.03, 1.22, 0.49, 1.65, 1.01, 1.46, 1.1, 0.97, 0.82, 1.17, 1.38, 1.25, 0.75, 1.41, 0.66, 1.79, 1.1, 0.85, 1.21, 1.19)
index <- c(70, 137, 110, 114, 77, 90, 85, 42, 162, 127, 142, 114, 100, 76, 122, 112, 119, 74, 105, 45, 158, 107, 70, 122, 92)

# This package require to enter list of years of observation, crop yield
# information, index for insurance design, price of crop yield and stricke level 
# for quantile regression. By default crop_price = 1 and strike_quantile = 0.3

climateinsurance(year, yield, index)

```

![](man/figure/figure1.png)<!-- -->

#### Result
``` r
   year index yield index_shortage yield_shortage revenue_losses  payout premium non_insured_revenue insured_revenue he_insurance he_noinsurance
1  1991  0.69    70          0.324             16             16 27.2389  6.2952                  70         90.9437     142.4749      1081.0944
2  1992  1.62   137          0.000              0              0  0.0000  6.2952                 137        130.7048       0.0000         0.0000
3  1993  1.04   110          0.000              0              0  0.0000  6.2952                 110        103.7048       0.0000         0.0000
4  1994  1.11   114          0.000              0              0  0.0000  6.2952                 114        107.7048       0.0000         0.0000
5  1995  1.10    77          0.000              9              9  0.0000  6.2952                  77         70.7048    1035.2449       669.7744
6  1996  1.03    90          0.000              0              0  0.0000  6.2952                  90         83.7048     367.6891       165.8944
7  1997  1.22    85          0.000              1              1  0.0000  6.2952                  85         78.7048     584.4413       319.6944
8  1998  0.49    42          0.524             44             44 44.0531  6.2952                  42         79.7579     534.6326      3706.3744
9  1999  1.65   162          0.000              0              0  0.0000  6.2952                 162        155.7048       0.0000         0.0000
10 2000  1.01   127          0.004              0              0  0.3363  6.2952                 127        121.0411       0.0000         0.0000
11 2001  1.46   142          0.000              0              0  0.0000  6.2952                 142        135.7048       0.0000         0.0000
12 2002  1.10   114          0.000              0              0  0.0000  6.2952                 114        107.7048       0.0000         0.0000
13 2003  0.97   100          0.044              0              0  3.6991  6.2952                 100         97.4039      29.9877         8.2944
14 2004  0.82    76          0.194             10             10 16.3097  6.2952                  76         86.0145     284.4446       722.5344
15 2005  1.17   122          0.000              0              0  0.0000  6.2952                 122        115.7048       0.0000         0.0000
16 2006  1.38   112          0.000              0              0  0.0000  6.2952                 112        105.7048       0.0000         0.0000
17 2007  1.25   119          0.000              0              0  0.0000  6.2952                 119        112.7048       0.0000         0.0000
18 2008  0.75    74          0.264             12             12 22.1947  6.2952                  74         89.8995     168.4942       834.0544
19 2009  1.41   105          0.000              0              0  0.0000  6.2952                 105         98.7048      17.4325         0.0000
20 2010  0.66    45          0.354             41             41 29.7611  6.2952                  45         68.4658    1184.3344      3350.0944
21 2011  1.79   158          0.000              0              0  0.0000  6.2952                 158        151.7048       0.0000         0.0000
22 2012  1.10   107          0.000              0              0  0.0000  6.2952                 107        100.7048       4.7316         0.0000
23 2013  0.85    70          0.164             16             16 13.7876  6.2952                  70         77.4924     644.5308      1081.0944
24 2014  1.21   122          0.000              0              0  0.0000  6.2952                 122        115.7048       0.0000         0.0000
25 2015  1.19    92          0.000              0              0  0.0000  6.2952                  92         85.7048     294.9882       118.3744
Call:
quantreg::rq(formula = calc_table$yield ~ calc_table$index, tau = strike_quantile)

Coefficients:
     (Intercept) calc_table$index 
       0.8053097       84.0707965 

Degrees of freedom: 25 total; 23 residual
$quantile_for_strike
[1] 0.3

$strike_level
[1] 1.014

$number_of_years
[1] 25

$number_of_losses
[1] 8

$number_of_payouts
[1] 8

$total_losses
[1] 149

$total_payouts
[1] 157.3805

$insurance_premium
[1] 6.29522

$ts
[1] 0.6

$pod
[1] 0.75

$far
[1] 0.25

$correlation
[1] 0.8787666

$rHE
[1] 0.5609766
```

![](man/figures/timeseries-1.png)<!-- -->

Moreover, based on this packege web-app has been developed under the link https://klimalez.org/climate-insurance
