Lesson 8: Problem Set - Explore Many Variables
================
Dannyel Cardoso da Fonseca
2017-12-07

### Load Libraries and Datasets

``` r
library(ggplot2)

data(diamonds)
pf <- read.delim('lesson_08_files/data/pseudo_facebook.tsv')
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
  scale_color_brewer(type = 'qual')
```

![](lesson_08_files/figure-markdown_github-ascii_identifiers/Price%20vs.%20Table%20Colored%20by%20Cut-1.png)

### Typical Table Value

**Quiz:** What is the typical table range for the majority of diamonds of ideal cut?

**Response:** 53 to 57.

**Quiz:** What is the typical table range for the majority of diamonds of premium cut?

**Response:** 58 to 62.

### Price vs. Volume and Diamond Clarity

**Quiz:** Create a scatterplot of diamond price vs. volume (x \* y \* z) and color the points by the clarity of diamonds. Use scale on the y-axis to take the log10 of price. You should also omit the top 1% of diamond volumes from the plot.

> Note: Volume is a very rough approximation of a diamond's actual volume.

The plot should look something like this. <http://i.imgur.com/excUpea.jpg>

> Note: In the link, a color palette of type 'div' was used to color the scatterplot using scale\_color\_brewer(type = 'div')

**Response:**

``` r
diamonds <- transform(diamonds, volume = x * y * z)
levels(diamonds$clarity) <- rev(levels(diamonds$clarity))
volume_99_quantile <- quantile(diamonds$volume, .99)

ggplot(subset(diamonds, volume > 0), aes(x = volume, y = price)) +
  geom_point(aes(color = clarity), position = position_jitter(width = .1), alpha = .3, na.rm = TRUE) +
  scale_x_continuous(limits = c(0, volume_99_quantile), breaks = seq(0, volume_99_quantile, 25)) +
  scale_y_log10() +
  scale_color_brewer(type = 'div')
```

![](lesson_08_files/figure-markdown_github-ascii_identifiers/Price%20vs.%20Volume%20and%20Diamond%20Clarity-1.png)

### Proportion of Friendships Initiated

**Quiz:** Many interesting variables are derived from two or more others. For example, we might wonder how much of a person's network on a service like Facebook the user actively initiated. Two users with the same degree (or number of friends) might be very different if one initiated most of those connections on the service, while the other initiated very few. So it could be useful to consider this proportion of existing friendships that the user initiated. This might be a good predictor of how active a user is compared with their peers, or other traits, such as personality (i.e., is this person an extrovert?).

Your task is to create a new variable called 'prop\_initiated' in the Pseudo-Facebook data set. The variable should contain the proportion of friendships that the user initiated.

**Response:**

``` r
pf <- transform(pf, prop_initiated = ifelse(friend_count == 0, 0, friendships_initiated/friend_count))
```
