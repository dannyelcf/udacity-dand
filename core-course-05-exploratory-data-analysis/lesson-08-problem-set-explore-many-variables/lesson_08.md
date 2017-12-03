Lesson 8: Problem Set - Explore Many Variables
================
Dannyel Cardoso da Fonseca
2017-12-03

### Load Libraries and Datasets

``` r
library(ggplot2)

data(diamonds)
```

### Price Histograms with Facet and Color

**Quiz:** Create a histogram of diamond prices. Facet the histogram by diamond color and use cut to color the histogram bars.

The plot should look something like this: <http://i.imgur.com/b5xyrOu.jpg>

> Note: In the link, a color palette of type 'qual' was used to color the histogram using scale\_fill\_brewer(type = 'qual')

**Response:**

``` r
ggplot(diamonds, aes(x = price, fill = cut)) +
  geom_histogram(bins = 30) +
  facet_wrap(~color) +
  scale_x_log10() +
  scale_fill_brewer(type = 'qual')
```

![](lesson_08_files/figure-markdown_github-ascii_identifiers/Price%20Histograms%20with%20Facet%20and%20Color-1.png)

### Price vs. Table Colored by Cut

**Quiz:** Create a scatterplot of diamond price vs. table and color the points by the cut of the diamond.

The plot should look something like this: <http://i.imgur.com/rQF9jQr.jpg>

> Note: In the link, a color palette of type 'qual' was used to color the scatterplot using scale\_color\_brewer(type = 'qual')

**Response:**

``` r
ggplot(diamonds, aes(x = table, y = price)) +
  geom_point(aes(color = cut), position = position_jitter(width = .1), alpha = .3, na.rm = TRUE) +
  scale_x_continuous(limits = c(50, 80), breaks = seq(50, 80, 2)) +
  scale_y_continuous(breaks = seq(0, 20000, 1000)) +
  scale_fill_brewer(type = 'qual')
```

![](lesson_08_files/figure-markdown_github-ascii_identifiers/Price%20vs.%20Table%20Colored%20by%20Cut-1.png)
