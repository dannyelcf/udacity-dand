Lesson 9: Diamonds & Price Predictions
================
Dannyel Cardoso da Fonseca
2017-12-23

### Load Libraries and Datasets

``` r
library(ggplot2, warn.conflicts = FALSE)
library(gridExtra, warn.conflicts = FALSE)
library(GGally, warn.conflicts = FALSE)
library(scales, warn.conflicts = FALSE)
library(RColorBrewer, warn.conflicts = FALSE)
library(memisc, warn.conflicts = FALSE)
```

    ## Warning: package 'memisc' was built under R version 3.4.3

    ## Loading required package: lattice

    ## Loading required package: MASS

``` r
theme_set(theme_light())

data(diamonds)
```

### Welcome!

> Note: <https://www.youtube.com/watch?v=KJT4Z0xpHns>

### Linear Regression Models

> Note: In this lesson, Solomon will be using a linear regression model to predict diamond price using other variables in the diamonds dataset. If you are not familiar with linear regression, you may want to take a break and go through [Lesson 18 of Udacity's Intro to Inferential Statistics](https://classroom.udacity.com/courses/ud201/lessons/1309228537/concepts/1822138740923) course, which covers linear regression. When you're done, you'll be ready to come back and apply your new knowledge to the diamonds dataset!

### Scatterplot Review

> Note: <https://www.youtube.com/watch?v=W96zaGEma7o>

**Quiz:** Let's start by examining two variables in the data set. The scatterplot is a powerful tool to help you understand the relationship between two continuous variables.

We can quickly see if the relationship is linear or not. In this case, we can use a variety of diamond characteristics to help us figure out whether the price advertised for any given diamond is reasonable or a rip-off.

Let's consider the price of a diamond and it's carat weight. Create a scatterplot of price (y) vs carat weight (x).

Limit the x-axis and y-axis to omit the top 1% of values.

**Response:**

``` r
ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(alpha = 1/10, na.rm = TRUE) +
  scale_x_continuous(limits = c(0, quantile(diamonds$carat, .99)),
                     breaks = seq(0, 2.5, 0.25)) +
  scale_y_continuous(limits = c(0, quantile(diamonds$price, .99)),
                     breaks = seq(0, 20000, 1500))
```

![](lesson_09_files/figure-markdown_github-ascii_identifiers/Scatterplot%20Review-1.png)

### Price and Carat Relationship

> Note: <https://www.youtube.com/watch?v=gG4xwgj1yVA>

**Quiz:** What do you notice about the relationship between price and carat?

**Response:** Apparently, as carat increases the price increase as well, in a non-linear way. As carat increases price dispersion increases as well.

``` r
ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(alpha = 1/10, na.rm = TRUE) +
  geom_smooth(method = "lm", na.rm = TRUE) +
  scale_x_continuous(limits = c(0, quantile(diamonds$carat, .99)),
                     breaks = seq(0, 2.5, 0.25)) +
  scale_y_continuous(limits = c(0, quantile(diamonds$price, .99)),
                     breaks = seq(0, 20000, 1500))
```

![](lesson_09_files/figure-markdown_github-ascii_identifiers/Price%20and%20Carat%20Relationship-1.png)

### Frances Gerety

> Note: <https://www.youtube.com/watch?v=GXT_vXBA0vQ>

**Quiz:** Frances Gerety coined a famous slogan.

**Response:** "A diamond is forever."

### The Rise of Diamonds

> Note: <https://www.youtube.com/watch?v=MD9RIDRVc-A>

### ggpairs Function

> Note: <https://www.youtube.com/watch?v=iJEBxsKDDoE>

**Quiz:** What do you notice in the plot matrix from the ggpairs() function?

    # sample 10,000 diamonds from the data set.
    set.seed(20022012)
    diamond_samp <- diamonds[sample(1:length(diamonds$price), 10000), ]
    ggpairs(diamond_samp, axisLabels = 'internal',
      lower = list(continuous = wrap("points", shape = I('.'))),
      upper = list(combo = wrap("box", outlier.shape = I('.'))))

<img src="lesson_09_files/figure-markdown_github-ascii_identifiers/ggpairs_landscape.png" style="width:75.0%" />

**Response:**

-   **Relationship among x y and z dimensions**: it is obvious that there is a strong correlation among dimensions of diamond. That correlation is linear. As one dimension increases the others increase as well, in the same proportion.

<img src="lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_among_x_y_z.png" style="width:75.0%" />

-   **Relationship between price and diamond dimensions**: in data set, apparently, there is a strong correlation between price and diamond dimensions. That correlation appears to be logarithmic.

<img src="lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_price_with_x_y_z.png" style="width:75.0%" />

-   **Relationship of carat with color and clarity**: in data set, weightiest diamonds have worst colour and worst clarity. But the worst color diamonds are proportionately in smaller quantity while the diamonds of color clarity are proportionately in greater quantity. Summing up, the best clarity diamonds there are in smaller quantity and tend to be lighter and have better color.

<img src="lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_carat_with_color_clarity.png" style="width:75.0%" />

-   **Relationship among carat, price and diamond dimensions**: in data set, there is a strong correlation among carat, price and diamond dimensions. The correlation seems to be exponential between carat and diamond price and appears to be logarithmic between carat and diamond dimensions.

<img src="lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_carat_with_price_x_y_z.png" style="width:75.0%" />

-   **Relationship among color, clarity and diamond dimensions**: in data set, there is a certain correlation among color, clarity and diamond dimensions. This can be seen in the faceted boxplot. Diamonds with larger dimensions tend to have worst colors and clarities while diamonds with smaller dimensions tend to have best colors and clarities.

<img src="lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_color_and_clarity_with_x_y_z.png" style="width:75.0%" />

-   **Relationship among price, cut, color and clarity**: in data set, apparently, there is no significant correlation among price, cut, color and clarity. There is a little variability in the faceted bloxplots and faceted histogram.

<img src="lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_cut_color_clarity_with_price.png" style="width:75.0%" />

### The Demand of Diamonds

> Note: <https://www.youtube.com/watch?v=h-YgETh80h4>

**Quiz:** Create two histograms of the price variable and place on one output image.

The first plot should be a histogram of price and the second plot should transform the price variable using log10.

**Response:**

``` r
p1 <- ggplot(diamonds, aes(x = price)) +
        geom_histogram(bins = 30) +
        scale_x_continuous(breaks = seq(0, 20000, 1500)) +
        scale_y_continuous(breaks = seq(0, 15000, 2000)) +
        ggtitle('Price')

p2 <- ggplot(diamonds, aes(x = price)) +
        geom_histogram(bins = 30) +
        scale_x_log10() +
        scale_y_continuous(breaks = seq(0, 4000, 500)) +
        ggtitle('Price (log10)')

grid.arrange(p1, p2)
```

![](lesson_09_files/figure-markdown_github-ascii_identifiers/The%20Demand%20of%20Diamonds-1.png)

### Connecting Demand and Price Distribution

> Note: <https://www.youtube.com/watch?v=Rj6g9jpX9MQ>

**Quiz:** When looking at these plots, what do you notice? Think specifically about the two peaks in the transformed plot and how it relates to the demand for diamonds.

**Response:** I notice that about half of diamonds have prices that are below $3,000. Above this value, diamond prices disperse into a long tail in the histogram. After log10 transformation I notice that the long tail is highly representative appearing to be the majority of diamond prices. The target audience of the first peak is the large mass of people, with lower purchasing power. Already the target audience of the second peak are people with greater purchasing power and who seeks to differentiate themselves from the great mass of people.

### Scatterplot Transformation

> Note: <https://www.youtube.com/watch?v=h1wbEPuADz0>

``` r
# carat = weight of the diamond = f(volume) = f(x.y.z)
cuberoot_trans <- function() {
  trans_new("cuberoot",
            transform = function(x) x ^ (1/3), # cubic root
            inverse = function(x) x ^ 3)
}

ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(na.rm = TRUE) +
  scale_x_continuous(trans = cuberoot_trans(), 
                     limits = c(.2, 3),
                     breaks = c(.2, .5, 1, 2, 3)) +
  scale_y_continuous(trans = log10_trans(), 
                     limits = c(350,15000),
                     breaks = c(350, 1000, 5000, 10000, 15000)) +
  ggtitle("Price (log10) by cube root of carat")
```

![](lesson_09_files/figure-markdown_github-ascii_identifiers/Scatterplot%20Transformation-1.png)

### Overplotting Revisited

> Note: <https://www.youtube.com/watch?v=P6ZOr7JiMLk>

**Quiz:** Add a layer to adjust the features of the scatterplot. Set the transparency to one half, the size to three-fourths, and jitter the points.

**Response:**

``` r
ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(alpha = 1/2, size = 3/4, position = position_jitter(), na.rm = TRUE) +
  scale_x_continuous(trans = cuberoot_trans(), 
                     limits = c(.2, 3),
                     breaks = c(.2, .5, 1, 2, 3)) +
  scale_y_continuous(trans = log10_trans(), 
                     limits = c(350,15000),
                     breaks = c(350, 1000, 5000, 10000, 15000)) +
  ggtitle("Price (log10) by cube root of carat")
```

![](lesson_09_files/figure-markdown_github-ascii_identifiers/Overplotting%20Revisited-1.png)

### Plot Colors for Qualitative Factors

> Note: <https://www.youtube.com/watch?v=2ZVGl6LrOPw>

### Price vs. Carat and Clarity

> Note: <https://www.youtube.com/watch?v=J0Ls7F-lN4o>

**Quiz:** Adjust the code below to color the points by clarity.

A layer called scale\_color\_brewer() has been added to adjust the legend and provide custom colors.

**Response:**

``` r
ggplot(diamonds, aes(x = carat, y = price, color = clarity)) +
  geom_point(alpha = 1/2, size = 3/4, position = position_jitter(), na.rm = TRUE) +
  scale_color_brewer(type = 'div',
                     guide = guide_legend(title = 'Clarity', 
                                          reverse = TRUE,
                                          override.aes = list(alpha = 1, size = 2))) +
  scale_x_continuous(trans = cuberoot_trans(), 
                     limits = c(.2, 3),
                     breaks = c(.2, .5, 1, 2, 3)) +
  scale_y_continuous(trans = log10_trans(), 
                     limits = c(350,15000),
                     breaks = c(350, 1000, 5000, 10000, 15000)) +
  ggtitle('Price (log10) by Cube-Root of Carat and Clarity')
```

![](lesson_09_files/figure-markdown_github-ascii_identifiers/Price%20vs.%20Carat%20and%20Clarity-1.png)

### Clarity and Price

> Note: <https://www.youtube.com/watch?v=UnkrtPPx9-c>

**Quiz:** Based on the plot, do you think clarity explain some of the change in price? Why?

**Response:** Yes! The dispersion of the price in a given carat is explained by the clarity of the diamond. The best clarity is more expensive than the worst clarity in a given carat.

### Price vs Carat and Cut

> Note: <https://www.youtube.com/watch?v=RF9V7l00a28>

**Quiz:** Let’s look at cut and see if we find a similar result.

**Response:**

``` r
ggplot(diamonds, aes(x = carat, y = price, color = cut)) +
  geom_point(alpha = 1/2, size = 3/4, position = position_jitter(), na.rm = TRUE) +
  scale_color_brewer(type = 'div',
                     guide = guide_legend(title = 'Cut', 
                                          reverse = TRUE,
                                          override.aes = list(alpha = 1, size = 2))) +
  scale_x_continuous(trans = cuberoot_trans(), 
                     limits = c(.2, 3),
                     breaks = c(.2, .5, 1, 2, 3)) +
  scale_y_continuous(trans = log10_trans(), 
                     limits = c(350,15000),
                     breaks = c(350, 1000, 5000, 10000, 15000)) +
  ggtitle('Price (log10) by Cube-Root of Carat and Cut')
```

![](lesson_09_files/figure-markdown_github-ascii_identifiers/Price%20vs%20Carat%20and%20Cut-1.png)

### Cut and Price

> Note: <https://www.youtube.com/watch?v=MZyle39D5Ks>

**Quiz:** Based on the plot, do you think cut accounts some of the change in price? Why?

**Response:** Practically not! In the dispersion of the price in a given carat, the Ideal and Premium predominate since the lowest price until the highest price.

### Price vs Carat and Color

> Note: <https://www.youtube.com/watch?v=ow70HVqX4OY>

**Quiz:** Finally, let’s use diamond color to color our plot.

**Response:**

``` r
ggplot(diamonds, aes(x = carat, y = price, color = color)) +
  geom_point(alpha = 1/2, size = 3/4, position = position_jitter(), na.rm = TRUE) +
  scale_color_brewer(type = 'div',
                     guide = guide_legend(title = 'Color', 
                                          override.aes = list(alpha = 1, size = 2))) +
  scale_x_continuous(trans = cuberoot_trans(), 
                     limits = c(.2, 3),
                     breaks = c(.2, .5, 1, 2, 3)) +
  scale_y_continuous(trans = log10_trans(), 
                     limits = c(350,15000),
                     breaks = c(350, 1000, 5000, 10000, 15000)) +
  ggtitle('Price (log10) by Cube-Root of Carat and Color')
```

![](lesson_09_files/figure-markdown_github-ascii_identifiers/Price%20vs%20Carat%20and%20Color-1.png)

### Color and Price

> Note: <https://www.youtube.com/watch?v=-9CHGW25yMg>

**Quiz:** Based on the plot, do you think that the diamond color influences price? Why?

**Response:** Yes! Color influences prices in the same way that clarity do. The diamond with best color is more expensive than diamond with the worst color in a given carat.

### Linear Models in R

> Note: <https://www.youtube.com/watch?v=a2GCyz_N0oY>

<img src="lesson_09_files/figure-markdown_github-ascii_identifiers/19%20-%20Quiz%20-%20Linear%20Models%20in%20R.png" style="width:75.0%" />

### Building the Linear Model

> Note: <https://www.youtube.com/watch?v=zyIc0sXYk2A>

``` r
m1 <- lm(I(log(price)) ~ I(carat^(1/3)), data = diamonds)
m1 
```

    ## 
    ## Call:
    ## lm(formula = I(log(price)) ~ I(carat^(1/3)), data = diamonds)
    ## 
    ## Coefficients:
    ##    (Intercept)  I(carat^(1/3))  
    ##          2.821           5.558

``` r
m2 <- update(m1, ~ . + carat)
m2
```

    ## 
    ## Call:
    ## lm(formula = I(log(price)) ~ I(carat^(1/3)) + carat, data = diamonds)
    ## 
    ## Coefficients:
    ##    (Intercept)  I(carat^(1/3))           carat  
    ##          1.039           8.568          -1.137

``` r
m3 <- update(m2, ~ . + cut)
m3
```

    ## 
    ## Call:
    ## lm(formula = I(log(price)) ~ I(carat^(1/3)) + carat + cut, data = diamonds)
    ## 
    ## Coefficients:
    ##    (Intercept)  I(carat^(1/3))           carat           cut.L  
    ##        0.87436         8.70286        -1.16327         0.22437  
    ##          cut.Q           cut.C           cut^4  
    ##       -0.06241         0.05100         0.01801

``` r
m4 <- update(m3, ~ . + color)
m4
```

    ## 
    ## Call:
    ## lm(formula = I(log(price)) ~ I(carat^(1/3)) + carat + cut + color, 
    ##     data = diamonds)
    ## 
    ## Coefficients:
    ##    (Intercept)  I(carat^(1/3))           carat           cut.L  
    ##        0.93176         8.43797        -0.99189         0.22409  
    ##          cut.Q           cut.C           cut^4         color.L  
    ##       -0.06191         0.05154         0.01826        -0.37342  
    ##        color.Q         color.C         color^4         color^5  
    ##       -0.12906         0.00143         0.02857        -0.01640  
    ##        color^6  
    ##       -0.02348

``` r
m5 <- update(m4, ~ . + clarity)
m5
```

    ## 
    ## Call:
    ## lm(formula = I(log(price)) ~ I(carat^(1/3)) + carat + cut + color + 
    ##     clarity, data = diamonds)
    ## 
    ## Coefficients:
    ##    (Intercept)  I(carat^(1/3))           carat           cut.L  
    ##       0.414792        9.144314       -1.092551        0.119825  
    ##          cut.Q           cut.C           cut^4         color.L  
    ##      -0.031025        0.013578       -0.001884       -0.440905  
    ##        color.Q         color.C         color^4         color^5  
    ##      -0.092790       -0.013299        0.012047       -0.003204  
    ##        color^6       clarity.L       clarity.Q       clarity.C  
    ##       0.001330        0.907144       -0.239602        0.130897  
    ##      clarity^4       clarity^5       clarity^6       clarity^7  
    ##      -0.062759        0.025752       -0.002090        0.031982

``` r
mtable(m1, m2, m3, m4, m5, sdigits = 3)
```

    ## 
    ## Calls:
    ## m1: lm(formula = I(log(price)) ~ I(carat^(1/3)), data = diamonds)
    ## m2: lm(formula = I(log(price)) ~ I(carat^(1/3)) + carat, data = diamonds)
    ## m3: lm(formula = I(log(price)) ~ I(carat^(1/3)) + carat + cut, data = diamonds)
    ## m4: lm(formula = I(log(price)) ~ I(carat^(1/3)) + carat + cut + color, 
    ##     data = diamonds)
    ## m5: lm(formula = I(log(price)) ~ I(carat^(1/3)) + carat + cut + color + 
    ##     clarity, data = diamonds)
    ## 
    ## ============================================================================================
    ##                        m1             m2             m3             m4            m5        
    ## --------------------------------------------------------------------------------------------
    ##   (Intercept)          2.821***       1.039***       0.874***      0.932***       0.415***  
    ##                       (0.006)        (0.019)        (0.019)       (0.017)        (0.010)    
    ##   I(carat^(1/3))       5.558***       8.568***       8.703***      8.438***       9.144***  
    ##                       (0.007)        (0.032)        (0.031)       (0.028)        (0.016)    
    ##   carat                              -1.137***      -1.163***     -0.992***      -1.093***  
    ##                                      (0.012)        (0.011)       (0.010)        (0.006)    
    ##   cut: .L                                            0.224***      0.224***       0.120***  
    ##                                                     (0.004)       (0.004)        (0.002)    
    ##   cut: .Q                                           -0.062***     -0.062***      -0.031***  
    ##                                                     (0.004)       (0.003)        (0.002)    
    ##   cut: .C                                            0.051***      0.052***       0.014***  
    ##                                                     (0.003)       (0.003)        (0.002)    
    ##   cut: ^4                                            0.018***      0.018***      -0.002     
    ##                                                     (0.003)       (0.002)        (0.001)    
    ##   color: .L                                                       -0.373***      -0.441***  
    ##                                                                   (0.003)        (0.002)    
    ##   color: .Q                                                       -0.129***      -0.093***  
    ##                                                                   (0.003)        (0.002)    
    ##   color: .C                                                        0.001         -0.013***  
    ##                                                                   (0.003)        (0.002)    
    ##   color: ^4                                                        0.029***       0.012***  
    ##                                                                   (0.003)        (0.002)    
    ##   color: ^5                                                       -0.016***      -0.003*    
    ##                                                                   (0.003)        (0.001)    
    ##   color: ^6                                                       -0.023***       0.001     
    ##                                                                   (0.002)        (0.001)    
    ##   clarity: .L                                                                     0.907***  
    ##                                                                                  (0.003)    
    ##   clarity: .Q                                                                    -0.240***  
    ##                                                                                  (0.003)    
    ##   clarity: .C                                                                     0.131***  
    ##                                                                                  (0.003)    
    ##   clarity: ^4                                                                    -0.063***  
    ##                                                                                  (0.002)    
    ##   clarity: ^5                                                                     0.026***  
    ##                                                                                  (0.002)    
    ##   clarity: ^6                                                                    -0.002     
    ##                                                                                  (0.002)    
    ##   clarity: ^7                                                                     0.032***  
    ##                                                                                  (0.001)    
    ## --------------------------------------------------------------------------------------------
    ##   R-squared            0.924          0.935          0.939         0.951          0.984     
    ##   adj. R-squared       0.924          0.935          0.939         0.951          0.984     
    ##   sigma                0.280          0.259          0.250         0.224          0.129     
    ##   F               652012.063     387489.366     138654.523     87959.467     173791.084     
    ##   p                    0.000          0.000          0.000         0.000          0.000     
    ##   Log-likelihood   -7962.499      -3631.319      -1837.416      4235.240      34091.272     
    ##   Deviance          4242.831       3613.360       3380.837      2699.212        892.214     
    ##   AIC              15930.999       7270.637       3690.832     -8442.481     -68140.544     
    ##   BIC              15957.685       7306.220       3761.997     -8317.942     -67953.736     
    ##   N                53940          53940          53940         53940          53940         
    ## ============================================================================================
