load_dataset <- function(path) {
  # Load the Issues Tracking Data Set
  setClass('date_ymd_hms')
  setAs("character","date_ymd_hms", function(from) ymd_hms(from))
  setClass('date_ymd')
  setAs("character", "date_ymd", function(from) ymd(from))
  setClass('time_period')
  setAs("character", "time_period", function(from) seconds_to_period(from))
  setClass('factor_issue_priority_scale')
  setAs("character", "factor_issue_priority_scale", 
        function(from) {
          factor(from, levels = c("SUSPENDED",
                                  "LOW",
                                  "MEDIUM",
                                  "HIGH",
                                  "URGENT",
                                  "BLOCKING"))
        })
  issues <- read.csv(path, 
                     stringsAsFactors=FALSE, 
                     na.strings = "",
                     colClasses = c("integer", # issue_id
                                    "integer", # issue_number
                                    "character", # issue_title
                                    "factor", # issue_type
                                    "date_ymd_hms", # issue_creation_date
                                    "factor", # issue_system
                                    "date_ymd", # issue_start_date
                                    "factor", # issue_subsystem
                                    "date_ymd", # issue_deadline_date
                                    "character", # issue_created_by
                                    "factor", # issue_stakeholder
                                    "factor", # issue_status
                                    "time_period", # issue_time_spent
                                    "integer", # issue_priority_number
                                    "integer", # issue_progress
                                    "factor_issue_priority_scale",  # issue_priority_scale
                                    "character", # log_build_info
                                    "date_ymd_hms",  # log_creation_date
                                    "factor", # log_action
                                    "factor", # log_status
                                    "integer", # log_progress
                                    "time_period", # log_time_spent
                                    "character", # log_created_by 
                                    "integer" # log_svn_revision 
                     ))
}


df_summary <- function(df) {
  data.frame(min = min(df$score), 
             max = max(df$score),
             mean = mean(df$score),
             qu1 = quantile(df$score, probs = .25, names = FALSE),
             median = quantile(df$score, probs = .5, names = FALSE),
             qu3 = quantile(df$score, probs = .75, names = FALSE),
             pc95 = quantile(df$score, probs = .95, names = FALSE),
             iqr = (quantile(df$score, probs = .75, names = FALSE) - 
                      quantile(df$score, probs = .25, names = FALSE)))
}


df_summary_text <- function(df_summary) {
  paste0("min: ", df_summary$min,
         "    1st qu.: ", df_summary$qu1,
         "    median: ", df_summary$median,
         "    mean: ", round(df_summary$mean,2),
         "    3rd qu.: ", df_summary$qu3,
         "    95 %: ", df_summary$pc95,
         "    max: ", df_summary$max)
}

plot_frequency.numeric <- function(df, x = NULL, y = NULL, summary = NULL,
                                   x.breaks = waiver(), y.breaks = waiver(),
                                   x.limits = NULL, y.limits = NULL, 
                                   labs.title = "", labs.x = "") {
  if(is.null(df)) {
    stop("df argument can't be NULL")
  }
  
  x <- eval(substitute(x), df)
  y <- eval(substitute(y), df)
  
  if(is.null(x)) {
    stop("x argument can't be NULL")
  }
  
  if(is.null(y)) {
    stop("y argument can't be NULL")
  }
  
  if(is.null(y)) {
    stop("y argument can't be NULL")
  }
  
  if(is.null(summary)) {
    summary <- df_summary(df)
  }
  
  if (is.null(y.limits)) {
    y.limits <- c(min(y), max(y))
  }
  
  summary.y <- y.limits[1] - 35
  
  df %>% 
    ggplot(aes(x = x, y = y)) +
    geom_bar(stat = "identity", alpha = .6) +
    scale_x_continuous(breaks = x.breaks, limits = x.limits) +
    scale_y_continuous(breaks = y.breaks, limits = c(summary.y, y.limits[2])) +
    labs(title = labs.title,
         subtitle = df_summary_text(summary),
         x = labs.x,
         y = "Frequency") +
    
    # Summaries....
    # 1st quantile
    annotate("segment", 
             x = summary$qu1, 
             xend = summary$median, 
             y = summary.y, yend = summary.y, colour = "black", 
             size = .5, 
             arrow = arrow(ends="first", angle=90, length=unit(.15,"cm"))) +
    # 2nd quantile (median)
    annotate("segment", 
             x = summary$median, 
             xend = summary$median, 
             y = summary.y, yend = summary.y, colour = "black", 
             size = 1, 
             arrow = arrow(ends="both", angle=90, length=unit(.15,"cm"))) +
    # 3rd quantile
    annotate("segment", 
             x = summary$median, 
             xend = summary$qu3, 
             y = summary.y, yend = summary.y, colour = "black", 
             size = .5, 
             arrow = arrow(ends="last", angle=90, length=unit(.15,"cm"))) +
    # Lower outlier limiar (1st qu. - IQR * 1.5)
    annotate("segment", 
             x = if(summary$qu1 - (summary$iqr * 1.5) < summary$min) {
                   summary$min
                 } else {
                   summary$qu1 - (summary$iqr * 1.5)
                 }, 
             xend = summary$qu1, 
             y = summary.y, yend = summary.y, colour = "black", 
             size = .5) +
    # Upper outlier limiar (3st qu. + IQR * 1.5)
    annotate("segment", 
             x = summary$qu3, 
             xend = if(summary$qu3 + (summary$iqr * 1.5) > summary$max) {
                      summary$max
                    } else {
                      summary$qu3 + (summary$iqr * 1.5)
                    }, 
             y = summary.y, yend = summary.y, colour = "black", 
             size = .5) +
    # Mean
    annotate("point", 
             x = summary$mean, y = summary.y, 
             colour = "red", size = 1.2) 
}

plot_frequency.month <- function(df, x = NULL, y = NULL, summary = NULL,
                                 y.breaks = waiver(),
                                 labs.title = "", labs.x = "") 
{
  if(is.null(df)) {
    stop("df argument can't be NULL")
  }
  
  x <- eval(substitute(x), df)
  y <- eval(substitute(y), df)
  
  if(is.null(x)) {
    stop("x argument can't be NULL")
  }
  
  if(is.null(y)) {
    stop("y argument can't be NULL")
  }
  
  if(is.null(summary)) {
    summary <- df_summary(df)
  }
  
  df %>%
    # Create cumulative summaries variables
    mutate(cummean = sapply(seq_along(y), 
                            function(n){mean(y[1:n])}),
           cummedian = sapply(seq_along(y), 
                              function(n){median(y[1:n])}),
           cum1stqu = sapply(seq_along(y), 
                             function(n){quantile(y[1:n], probs = .25)}),
           cum3rdqu = sapply(seq_along(y), 
                             function(n){quantile(score[1:n], probs = .75)})) %>%
    ggplot(aes(x = x, y = y)) +
      geom_bar(stat = "identity", alpha = .6) +
      scale_x_date(date_breaks = "2 month", date_labels = "%b %Y",
                   limits = c(min(x), max(x) + months(2))) +
      scale_y_continuous(breaks = y.breaks) +
      # Rotate axis x
      theme(axis.text.x = element_text(angle = 40, hjust = 1)) +
      labs(title = labs.title,
           subtitle = paste("", df_summary_text(summary)),
         x = labs.x,
         y = "Frequency") +
      # Summary lines
      geom_line(aes(x = x, y = cummedian), 
                linetype = 2, color = "black") +
      geom_line(aes(x = x, y = cum1stqu), 
                linetype = 3, color = "black") +
      geom_line(aes(x = x, y = cum3rdqu), 
                linetype = 3, color = "black") +
      geom_line(aes(x = x, y = cummean), 
                linetype = 1, color = "red") +
      # Labels of summary lines
      geom_text(data = summary, mapping = aes(x = max(x), 
                                              y = median, label = "median"), 
                size = 3, vjust = .3, hjust = -.1) +
      geom_text(data = summary, mapping = aes(x = max(x),
                                              y = qu1, label = "1st qu."), 
                size = 3, vjust = .3, hjust = -.1) +
      geom_text(data = summary, mapping = aes(x = max(x), 
                                              y = qu3, label = "3rd qu."), 
                size = 3, vjust = .3, hjust = -.1) +
      geom_text(data = summary, mapping = aes(x = max(x), 
                                              y = mean, label = "mean"), 
                size = 3, vjust = .3, hjust = -.1, color = "red") 
}

plot_frequency.factor <- function(df, x = NULL, y = NULL,
                                  x.breaks = seq(0, 1, .05),
                                  x.rotate = NULL, y.limits = c(0, 1), 
                                  labs.title = "", labs.x = "") 
{
  if(is.null(df)) {
    stop("df argument can't be NULL")
  }
  
  x <- eval(substitute(x), df)
  y <- eval(substitute(y), df)
  
  if(is.null(x)) {
    stop("x argument can't be NULL")
  }
  
  if(is.null(y)) {
    stop("y argument can't be NULL")
  }
  
  if(is.null(y)) {
    stop("y argument can't be NULL")
  }
  
  axis.text.x <- if (is.null(x.rotate)) {
    element_text(size = 7)
  } else {
    element_text(angle = x.rotate, hjust = 1, size = 7)
  }
  
  df %>% 
    ggplot(aes(x = reorder(x, -score), y = y/sum(y))) +
      geom_bar(stat = "identity", alpha = .6) +
      geom_text(aes(label = y), vjust = -1, size = 3) +
      scale_y_continuous(limits = y.limits, breaks = x.breaks) +
      theme(axis.text.x = axis.text.x) + 
      labs(title = labs.title,
           x = labs.x,
           y = "Frequency (relative)")
}