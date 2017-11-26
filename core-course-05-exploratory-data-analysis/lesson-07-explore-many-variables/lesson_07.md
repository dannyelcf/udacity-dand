Lesson 7: Explore Many Variables
================
Dannyel Cardoso da Fonseca
2017-11-26

### Load Libraries and Datasets

``` r
library(ggplot2)
library(dplyr, warn.conflicts = FALSE)

pf <- read.delim('lesson_07_files/data/pseudo_facebook.tsv')
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
```

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
