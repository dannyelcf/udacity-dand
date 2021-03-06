Lesson 8: Problem Set - Explore Many Variables
================
Dannyel Cardoso da Fonseca
2017-12-09

### Load Libraries and Datasets

``` r
library(ggplot2)
library(gridExtra, warn.conflicts = FALSE)

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

### prop\_initiated vs. tenure

**Quiz:** Create a line graph of the median proportion of friendships initiated ('prop\_initiated') vs. tenure and color the line segment by year\_joined.bucket.

Recall, we created year\_joined.bucket in Lesson 7 by first creating year\_joined from the variable tenure. Then, we used the cut function on year\_joined to create four bins or cohorts of users.

    (2004, 2009]
    (2009, 2011]
    (2011, 2012]
    (2012, 2014]

The plot should look something like this <http://i.imgur.com/vNjPtDh.jpg> OR this <http://i.imgur.com/IBN1ufQ.jpg>

**Response:**

``` r
pf <- transform(pf, year_joined = 2014 - ceiling(tenure/365))
unique(pf$year_joined)
```

    ##  [1] 2013 2014 2012 2011 2010 2009 2008 2007   NA 2006 2005

``` r
pf <- transform(pf, year_joined.bucket = cut(year_joined, breaks = c(2004, 2009, 2011, 2012, 2014)))
unique(pf$year_joined.bucket)
```

    ## [1] (2012,2014] (2011,2012] (2009,2011] (2004,2009] <NA>       
    ## Levels: (2004,2009] (2009,2011] (2011,2012] (2012,2014]

``` r
ggplot(subset(pf, !is.na(year_joined.bucket) & tenure > 0), 
       aes(x = tenure, y = prop_initiated)) +
  geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = median) +
  scale_x_continuous(breaks = seq(0, 3500, 250)) +
  scale_y_continuous(breaks = seq(0, 1, .1))
```

![](lesson_08_files/figure-markdown_github-ascii_identifiers/prop_initiated%20vs.%20tenure-1.png)

### Smoothing prop\_initiated vs. tenure

**Quiz:** Smooth the last plot you created of of prop\_initiated vs tenure colored by year\_joined.bucket. You can bin together ranges of tenure or add a smoother to the plot.

**Response:**

``` r
# bin together ranges of tenure
ggplot(subset(pf, !is.na(year_joined.bucket) & tenure > 0), 
       aes(x = 30 * round(tenure / 30), y = prop_initiated)) +
  geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = median) +
  scale_x_continuous(breaks = seq(0, 3500, 250)) +
  scale_y_continuous(breaks = seq(0, 1, .1))
```

![](lesson_08_files/figure-markdown_github-ascii_identifiers/Smoothing%20prop_initiated%20vs.%20tenure-1.png)

``` r
# add a smoother to the plot
ggplot(subset(pf, !is.na(year_joined.bucket) & tenure > 0), 
       aes(x = tenure, y = prop_initiated)) +
  geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = median) +
  geom_smooth() +
  scale_x_continuous(breaks = seq(0, 3500, 250)) +
  scale_y_continuous(breaks = seq(0, 1, .1))
```

    ## `geom_smooth()` using method = 'gam'

![](lesson_08_files/figure-markdown_github-ascii_identifiers/Smoothing%20prop_initiated%20vs.%20tenure-2.png)

### Greatest prop\_initiated Group

**Quiz:** On average, which group initiated the greatest proportion of its Facebook friendships? The plot with the smoother that you created in the last exercice can help you to answer this question.

**Response:** People who joined after 2012.

### Largest Group Mean prop\_initiated

**Quiz:** For the group with the largest proportion of friendships initiated, what is the group's average (mean) proportion of friendships initiated?

**Response:**

``` r
summary(subset(pf, year_joined.bucket == "(2012,2014]")$prop_initiated)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##  0.0000  0.5000  0.6912  0.6430  0.8438  1.0000

**Quiz:** Why do you think this group's proportion of friendships initiated is higher than others?

**Response:**

``` r
p1 <- ggplot(subset(pf, !is.na(year_joined.bucket) & tenure > 0), 
             aes(x = 30 * round(tenure / 30), y = prop_initiated)) +
        geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = median) +
        scale_x_continuous(breaks = seq(0, 3500, 250)) +
        scale_y_continuous(breaks = seq(0, 1, .1))

p2 <- ggplot(subset(pf, !is.na(year_joined.bucket) & tenure > 0), 
             aes(x = 30 * round(tenure / 30), y = age)) +
        geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = median) +
        scale_x_continuous(breaks = seq(0, 3500, 250)) +
        scale_y_continuous(breaks = seq(0, 150, 10))

grid.arrange(p1, p2, ncol = 1)
```

![](lesson_08_files/figure-markdown_github-ascii_identifiers/Largest%20Group%20Mean%20prop_initiated%202-1.png)

Seeing the line graphs of the median proportion of friendships initiated ('prop\_initiated') vs. tenure and of the median proportion of age vs. tenure we may note that prop\_initiated and age are inversely proportional. People who joined after 2012 are totally young (in average 25 years old) and tend to start more friends than older people.

### Price/Carat Binned, Faceted, & Colored

**Quiz:** Create a scatter plot of the price/carat ratio of diamonds. The variable x should be assigned to cut. The points should be colored by diamond color, and the plot should be faceted by clarity.

The plot should look something like this <http://i.imgur.com/YzbWkHT.jpg>.

> Note: In the link, a color palette of type 'div' was used to color the histogram using scale\_color\_brewer(type = 'div')

**Response:**

``` r
levels(diamonds$clarity) <- rev(levels(diamonds$clarity))

ggplot(subset(diamonds, volume > 0), aes(x = cut, y = price/carat)) +
  geom_point(aes(color = color), position = position_jitter(width = .3), alpha = .7, na.rm = TRUE) +
  facet_wrap(~clarity) +
  scale_color_brewer(type = 'div') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

![](lesson_08_files/figure-markdown_github-ascii_identifiers/Price/Carat%20Binned,%20Faceted,%20&%20Colored-1.png)

### Gapminder Multivariate Analysis

**Quiz:** The Gapminder website contains over 500 data sets with information about the world's population. Your task is to continue the investigation you did at the end of Problem Set 4 or you can start fresh and choose a different data set from Gapminder.

If you’re feeling adventurous or want to try some data munging see if you can find a data set or scrape one from the web.

In your investigation, examine 3 or more variables and create 2-5 plots that make use of the techniques from Lesson 7.

Once you've completed your investigation, create a post in the discussions that includes:

1.  the variable(s) you investigated, your observations, and any summary statistics
2.  snippets of code that created the plots
3.  links to the images of your plots

**Response:** TODO
