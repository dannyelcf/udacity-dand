Lesson 7: Explore Many Variables
================
Dannyel Cardoso da Fonseca
2017-12-02

### Load Libraries and Datasets

``` r
library(ggplot2)
library(dplyr, warn.conflicts = FALSE)
library(gridExtra, warn.conflicts = FALSE)

pf <- read.delim('lesson_07_files/data/pseudo_facebook.tsv')
yo <- read.csv("lesson_07_files/data/yogurt.csv")
yo$id <- as.factor(yo$id)
```

### Multivariate Data

> Note: <https://www.youtube.com/watch?v=jsg6lhrJN1g>

### Perceived Audience Size By Age

> Note: <https://www.youtube.com/watch?v=GFKRNBnFGVU>

### Third Qualitative Variable

> Note: <https://www.youtube.com/watch?v=Q2M8xyY47fc>

**Quiz:** Write code to create a new data frame, called 'pf.fc\_by\_age\_gender', that contains information on each age AND gender group.

The data frame should contain the following variables:

    mean_friend_count,
    median_friend_count,
    n (the number of users in each age and gender grouping)

**Response:**

``` r
pf.fc_by_age_gender <- pf %>% 
                          filter(!is.na(gender)) %>% 
                          group_by(age, gender) %>% 
                          summarise(mean_friend_count = mean(friend_count),
                                    median_friend_count = as.integer(median(friend_count)),
                                    n = n()) %>%                   
                          ungroup() %>% 
                          arrange(age, gender)

head(pf.fc_by_age_gender)
```

    ## # A tibble: 6 x 5
    ##     age gender mean_friend_count median_friend_count     n
    ##   <int> <fctr>             <dbl>               <int> <int>
    ## 1    13 female          259.1606                 148   193
    ## 2    13   male          102.1340                  55   291
    ## 3    14 female          362.4286                 224   847
    ## 4    14   male          164.1456                  92  1078
    ## 5    15 female          538.6813                 276  1139
    ## 6    15   male          200.6658                 106  1478

### Plotting Conditional Summaries

> Note: <https://www.youtube.com/watch?v=8SqL0v_FSsc>

**Quiz:** Create a line graph showing the median friend count over the ages for each gender. Be sure to use the data frame you just created, pf.fc\_by\_age\_gender.

**Response:**

``` r
ggplot(pf.fc_by_age_gender, aes(x = age, y = mean_friend_count)) +
  geom_line(aes(color = gender)) +
  scale_x_continuous(breaks = seq(10, 115, 5)) +
  scale_y_continuous(breaks = seq(0, 750, 50))
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Plotting%20Conditional%20Summaries-1.png)

### Thinking In Ratios

> Note: <https://www.youtube.com/watch?v=r4ZOwz3_oXs>

### Wide And Long Format

> Note: <https://www.youtube.com/watch?v=zlaeISxRESQ>

### Reshaping Data

> Note: <https://www.youtube.com/watch?v=zQj_waidR5w>

``` r
library(tidyr)
pf.fc_by_age_gender.wide <- pf.fc_by_age_gender %>% 
                               select(age, gender, median_friend_count) %>% 
                               spread(gender, median_friend_count)

head(pf.fc_by_age_gender.wide)
```

    ## # A tibble: 6 x 3
    ##     age female  male
    ##   <int>  <int> <int>
    ## 1    13    148    55
    ## 2    14    224    92
    ## 3    15    276   106
    ## 4    16    258   136
    ## 5    17    245   125
    ## 6    18    243   122

### Ratio Plot

> Note: <https://www.youtube.com/watch?v=gfZ7C-QBF0k>

**Quiz:** Plot the ratio of the female to male median friend counts using the data frame pf.fc\_by\_age\_gender.wide.

Think about what geom you should use. Add a horizontal line to the plot with a y intercept of 1, which will be the base line. Look up the documentation for geom\_hline to do that. Use the parameter linetype in geom\_hline to make the line dashed.

**Response:**

``` r
ggplot(pf.fc_by_age_gender.wide, aes(x = age, y = female/male)) +
  geom_line() +
  geom_hline(yintercept = 1, linetype = 2, alpha = .3) +
  scale_x_continuous(breaks = seq(10, 115, 5)) +
  scale_y_continuous(breaks = seq(0, 4.5, .25))
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Ratio%20Plot-1.png)

### Third Quantitative Variable

> Note: <https://www.youtube.com/watch?v=gpwlI9Wa8xI>

**Quiz:** Create a variable called year\_joined in the pf data frame using the variable tenure and 2014 as the reference year.

The variable year joined should contain the year that a user joined facebook.

**Response:**

``` r
pf$year_joined <- 2014 - ceiling(pf$tenure/365)

pf.fc_by_year_joined <- pf %>% 
                          filter(!is.na(year_joined)) %>% 
                          group_by(year_joined) %>% 
                          summarise(count = n())

ggplot(pf.fc_by_year_joined, aes(x = year_joined, y = count)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = count), vjust = -1, size=3) +
  scale_x_continuous(breaks = seq(2005, 2014, 1)) +
  scale_y_continuous(breaks = seq(0, 50000, 3000))
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Third%20Quantitative%20Variable-1.png)

### Cut a Variable

> Note: <https://www.youtube.com/watch?v=n0lluEhKUfQ>

**Quiz:** Create a new variable in the data frame called year\_joined.bucket by using the cut function on the variable year\_joined.

You need to create the following buckets for the new variable, year\_joined.bucket

    (2004, 2009]
    (2009, 2011]
    (2011, 2012]
    (2012, 2014]

Note that a parenthesis means exclude the year and a bracket means include the year.

**Response:**

``` r
pf$year_joined.bucket <- cut(pf$year_joined, breaks = c(2004, 2009, 2011, 2012, 2014))

unique(pf$year_joined.bucket)
```

    ## [1] (2012,2014] (2011,2012] (2009,2011] (2004,2009] <NA>       
    ## Levels: (2004,2009] (2009,2011] (2011,2012] (2012,2014]

### Plotting It All Together

> Note: <https://www.youtube.com/watch?v=CiS4rBbr6tw>

**Quiz:** Create a line graph of friend\_count vs. age so that each year\_joined.bucket is a line tracking the median user friend\_count across age. This means you should have four different lines on your plot.

You should subset the data to exclude the users whose year\_joined.bucket is NA.

**Response:**

``` r
ggplot(subset(pf, !is.na(year_joined.bucket)), aes(x = age, y = friend_count)) +
  geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = median) +
  scale_x_continuous(breaks = seq(10, 120, 10)) +
  scale_y_continuous(breaks = seq(0, 2000, 100))
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Plotting%20It%20All%20Together-1.png)

### Plot the Grand Mean

> Note: <https://www.youtube.com/watch?v=pxaXkCjukGM>

**Quiz:** Write code to do the following:

1.  Add another geom\_line to code below to plot the grand mean of the friend count vs age.

2.  Exclude any users whose year\_joined.bucket is NA.

3.  Use a different line type for the grand mean.

> As a reminder, the parameter linetype can take the values 0-6: 0 = blank, 1 = solid, 2 = dashed 3 = dotted, 4 = dotdash, 5 = longdash 6 = twodash

**Response:**

``` r
ggplot(subset(pf, !is.na(year_joined.bucket)), aes(x = age, y = friend_count)) +
  geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = mean) +
  geom_line(stat = "summary", fun.y = mean, linetype = 5) + # grand mean
  scale_x_continuous(breaks = seq(10, 120, 10)) +
  scale_y_continuous(breaks = seq(0, 2000, 100))
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Plot%20the%20Grand%20Mean-1.png)

### Friending Rate

> Note: <https://www.youtube.com/watch?v=ZO7y9tsSQ0A>

**Quiz:** Calculate how many friends does a user have for each day since they have started using the service.

What is the median friend rate?

What is the maximum friend rate?

**Response:**

``` r
with(subset(pf, tenure > 0), summary(friend_count/tenure))
```

    ##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
    ##   0.0000   0.0775   0.2205   0.6096   0.5658 417.0000

``` r
ggplot(subset(pf, tenure > 0), aes(y = friend_count/tenure, x = "")) +
  geom_boxplot() +
  geom_point(stat = "summary", fun.y = mean, color = "red") +
  coord_cartesian(ylim = c(0, 1.5)) +
  scale_y_continuous(breaks = seq(0, 1.5, .1)) +
  xlab("")
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Friending%20Rate-1.png)

### Friendships Initiated

> Note: <https://www.youtube.com/watch?v=Keh5GwaSWdk>

**Quiz:** Create a line graph of mean of friendships\_initiated per day (of tenure) vs. tenure colored by year\_joined.bucket.

You need to make use of the variables tenure, friendships\_initiated, and year\_joined.bucket.

You also need to subset the data to only consider user with at least one day of tenure.

**Response:**

``` r
ggplot(subset(pf, tenure > 0), aes(x = tenure, y = friendships_initiated/tenure)) +
  geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = mean) +
  scale_x_continuous(breaks = seq(0, 3500, 250)) +
  scale_y_continuous(breaks = seq(0, 10, .5))
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Friendships%20Initiated-1.png)

### Bias Variance Trade off Revisited

> Note: <https://www.youtube.com/watch?v=CSVf96g0XGM>

**Quiz:** Instead of geom\_line(), use geom\_smooth() to add a smoother to the plot. You can use the defaults for geom\_smooth() but do color the line by year\_joined.bucket

**Response:**

``` r
p1 <- ggplot(subset(pf, tenure > 0), aes(x = 7 * round(tenure / 7), y = friendships_initiated/tenure)) +
        geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = mean) +
        scale_x_continuous(breaks = seq(0, 3500, 250)) +
        scale_y_continuous(breaks = seq(0, 10, 1.5)) +
        ylab("fs_initiated/tenure")

p2 <- ggplot(subset(pf, tenure > 0), aes(x = 30 * round(tenure / 30), y = friendships_initiated/tenure)) +
        geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = mean) +
        scale_x_continuous(breaks = seq(0, 3500, 250)) +
        scale_y_continuous(breaks = seq(0, 10, 1)) +
        ylab("fs_initiated/tenure")

p3 <- ggplot(subset(pf, tenure > 0), aes(x = 90 * round(tenure / 90), y = friendships_initiated/tenure)) +
        geom_line(aes(color = year_joined.bucket), stat = "summary", fun.y = mean) +
        scale_x_continuous(breaks = seq(0, 3500, 250)) +
        scale_y_continuous(breaks = seq(0, 10, .5)) +
        ylab("fs_initiated/tenure")

grid.arrange(p1, p2, p3, ncol = 1)
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Bias%20Variance%20Trade%20off%20Revisited-1.png)

``` r
ggplot(subset(pf, tenure > 0), aes(x = 7 * round(tenure / 7), y = friendships_initiated /tenure)) +
  geom_smooth(aes(color = year_joined.bucket)) +
  scale_x_continuous(breaks = seq(0, 3500, 250)) +
  scale_y_continuous(breaks = seq(0, 4, .5)) 
```

    ## `geom_smooth()` using method = 'gam'

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Bias%20Variance%20Trade%20off%20Revisited-2.png)

### Sean's NFL Fan Sentiment Study

> Note: <https://www.youtube.com/watch?v=ahaxt6UKxQw>

### Introducing The Yogurt Dataset

> Note: <https://www.youtube.com/watch?v=5J9GxnJVo78>

### Histograms Revisited

> Note: <https://www.youtube.com/watch?v=7PyV7HxpSYA>

**Quiz:** Create a histogram of yogurt prices.

Use the qplot or ggplot syntax. Don't add any extra code for labels, titles, or colors. We're just looking for the basic syntax here.

**Response:**

``` r
ggplot(yo, aes(x = price)) +
  geom_histogram()
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Histograms%20Revisited%201-1.png)

I can note that the amount of yogurt increases as the price of yogurt increases. But the growth of yogurt quantity is not linear. It is intercalated between very low quantity and high quantity as the price increases.

``` r
ggplot(yo, aes(x = price)) +
  geom_histogram(binwidth = 10)
```

![](lesson_07_files/figure-markdown_github-ascii_identifiers/Histograms%20Revisited%202-1.png)

Now, I can note that the amount of yogurt increases as the price of yogurt increases in an exponential way.

### Number of Purchases

> Note: <https://www.youtube.com/watch?v=wZDgVcAW_es>

**Quiz:** Create a new variable called all.purchases, which gives the total counts of yogurt for each observation or household.

One way to do this is using the transform function. You can look up the function transform and run the examples of code at the bottom of the documentation to figure out what it does.

The transform function produces a data frame so if you use it then save the result to 'yo'!

Or you can figure out another way to create the variable.

**Response:**

``` r
yo <- transform(yo, all.purchases = strawberry + blueberry + pina.colada + plain + mixed.berry)

summary(yo$all.purchases)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   1.000   1.000   2.000   1.971   2.000  21.000
