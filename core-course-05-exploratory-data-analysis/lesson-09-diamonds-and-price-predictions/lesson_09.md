Lesson 9: Diamonds & Price Predictions
================
Dannyel Cardoso da Fonseca
2017-12-22

### Load Libraries and Datasets

``` r
library(ggplot2, warn.conflicts = FALSE)
library(gridExtra, warn.conflicts = FALSE)
library(GGally, warn.conflicts = FALSE)
library(scales, warn.conflicts = FALSE)
library(RColorBrewer, warn.conflicts = FALSE)
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
