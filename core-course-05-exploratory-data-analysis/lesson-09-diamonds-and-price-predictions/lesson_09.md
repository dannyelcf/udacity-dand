Lesson 9: Diamonds & Price Predictions
================
Dannyel Cardoso da Fonseca
2017-12-17

### Load Libraries and Datasets

``` r
library(ggplot2)
library(gridExtra, warn.conflicts = FALSE)
library(GGally)
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

![](lesson_09_files/figure-markdown_github-ascii_identifiers/ggpairs_landscape.png)

**Response:**

-   **Relationship among x y and z dimensions**: it is obvious that there is a strong correlation among dimensions of diamond. That correlation is linear. As one dimension increases the others increase as well, in the same proportion.

![](lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_among_x_y_z.png)

-   **Relationship between price and diamond dimensions**: in data set, apparently, there is a strong correlation between price and diamond dimensions. That correlation appears to be logarithmic.

![](lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_price_with_x_y_z.png)

-   **Relationship of carat with color and clarity**: in data set, weightiest diamonds have worst colour and worst clarity. But the worst color diamonds are proportionately in smaller quantity while the diamonds of color clarity are proportionately in greater quantity. Summing up, the best clarity diamonds there are in smaller quantity and tend to be lighter and have better color.

![](lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_carat_with_color_clarity.png)

-   **Relationship among carat, price and diamond dimensions**: in data set, there is a strong correlation among carat, price and diamond dimensions. The correlation seems to be exponential between carat and diamond price and appears to be logarithmic between carat and diamond dimensions.

![](lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_carat_with_price_x_y_z.png)

-   **Relationship among color, clarity and diamond dimensions**: in data set, there is a certain correlation among color, clarity and diamond dimensions. This can be seen in the faceted boxplot. Diamonds with larger dimensions tend to have worst colors and clarities while diamonds with smaller dimensions tend to have best colors and clarities.

![](lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_color_and_clarity_with_x_y_z.png)

-   **Relationship among price, cut, color and clarity**: in data set, apparently, there is no significant correlation among price, cut, color and clarity. There is a little variability in the faceted bloxplots and faceted histogram.

![](lesson_09_files/figure-markdown_github-ascii_identifiers/relationship_cut_color_clarity_with_price.png)
