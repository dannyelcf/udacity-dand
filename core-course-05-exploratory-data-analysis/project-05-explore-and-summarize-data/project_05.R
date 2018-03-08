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

df_summary <- function(df, variable = NULL) {
  df_summary_q(df, substitute(variable))
}

df_summary_q <- function(df, variable = NULL) {
  variable <- eval(variable, df)
  
  if(is.null(variable)) {
    stop("variable argument can't be NULL")
  }
  
  data.frame(min = min(variable), 
             max = max(variable),
             mean = mean(variable),
             qu1 = quantile(variable, probs = .25, names = FALSE),
             median = quantile(variable, probs = .5, names = FALSE),
             qu3 = quantile(variable, probs = .75, names = FALSE),
             pc95 = quantile(variable, probs = .95, names = FALSE),
             iqr = (quantile(variable, probs = .75, names = FALSE) - 
                      quantile(variable, probs = .25, names = FALSE)))
  
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

plot_histogram <- function(df, x = NULL, binwidth = 1, summary = NULL,
                           x.breaks = waiver(), y.breaks = waiver(),
                           x.limits = NULL, y.limits = NULL, 
                           xlim = NULL, ylim = NULL, x.rotate = NULL,
                           labs.title = "", labs.x = "", labs.caption = "") {
  if(is.null(df)) {
    stop("df argument can't be NULL")
  }
  
  x_q <- substitute(x)
  x <- eval(x_q, df)
  
  if(is.null(x)) {
    stop("x argument can't be NULL")
  }
  
  if(is.null(summary)) {
    summary <- df_summary_q(df, x_q)
  }
  
  axis.text.x <- if (is.null(x.rotate)) {
    element_text(size = 8.5)
  } else {
    element_text(angle = x.rotate, hjust = 1, size = 8.5)
  }
  
  summary.y <- 0
  
  df %>% 
    ggplot(aes(x = x)) +
    geom_histogram(alpha = .3, binwidth = binwidth, color = "gray",
                   boundary = summary$min, closed = "left") +
    scale_x_continuous(breaks = x.breaks, limits = x.limits) +
    scale_y_continuous(breaks = y.breaks, limits = y.limits) +
    coord_cartesian(xlim = xlim, ylim = ylim) +
    theme(axis.text.x = axis.text.x) + 
    labs(title = labs.title,
         subtitle = df_summary_text(summary),
         x = labs.x,
         y = "Frequency", 
         caption = labs.caption) +
    
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
             size = .15, linetype = 1,
             arrow = arrow(ends="first", angle=90, length=unit(.1,"cm"))) +
    # Upper outlier limiar (3st qu. + IQR * 1.5)
    annotate("segment", 
             x = summary$qu3, 
             xend = if(summary$qu3 + (summary$iqr * 1.5) > summary$max) {
               summary$max
             } else {
               summary$qu3 + (summary$iqr * 1.5)
             }, 
             y = summary.y, yend = summary.y, colour = "black", 
             size = .15, linetype = 1,
             arrow = arrow(ends="last", angle=90, length=unit(.1,"cm"))) +
    # Mean
    annotate("point", 
             x = summary$mean, y = summary.y, 
             colour = "red", size = 1.2) 
}

plot_frequency.month <- function(df, x = NULL, y = NULL, summary = NULL,
                                 y.breaks = waiver(),
                                 xlim = NULL, ylim = NULL,
                                 labs.title = "", labs.x = "", 
                                 labs.caption = "") {
  if(is.null(df)) {
    stop("df argument can't be NULL")
  }
  
  x_q <- substitute(x)
  x <- eval(x_q, df)
  y_q <- substitute(y)
  y <- eval(y_q, df)
  
  if(is.null(x)) {
    stop("x argument can't be NULL")
  }
  
  if(is.null(y)) {
    stop("y argument can't be NULL")
  }
  
  if(is.null(summary)) {
    summary <- df_summary_q(df, y_q)
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
      geom_col(alpha = .3, color = "grey", width = 28) +
      scale_x_date(date_breaks = "2 month", date_labels = "%b %Y",
                   limits = c(min(x), max(x) + months(2))) +
      scale_y_continuous(breaks = y.breaks) +
      coord_cartesian(xlim = xlim, ylim = ylim) +
      # Rotate axis x
      theme(axis.text.x = element_text(angle = 40, hjust = 1)) +
      labs(title = labs.title,
           subtitle = paste("", df_summary_text(summary)),
           x = labs.x,
           y = "Frequency",
           caption = labs.caption) +
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
                                  labs.title = "", labs.x = "", 
                                  labs.caption = "") {
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
  
  axis.text.x <- if (is.null(x.rotate)) {
    element_text(size = 7)
  } else {
    element_text(angle = x.rotate, hjust = 1, size = 7)
  }
  
  df %>% 
    ggplot(aes(x = reorder(x, -score), y = y/sum(y))) +
      geom_bar(stat = "identity", alpha = .3) +
      geom_text(aes(label = y), vjust = -1, size = 3) +
      scale_y_continuous(limits = y.limits, breaks = x.breaks) +
      theme(axis.text.x = axis.text.x) + 
      labs(title = labs.title,
           x = labs.x,
           y = "Frequency (relative)", 
           caption = labs.caption)
}

first_last_names <- function(names) {
  sapply(names, function(name) {
    name_splited <- unlist(strsplit(name, " "))
    if (length(name_splited) > 1) {
      paste(name_splited[1], name_splited[length(name_splited)])
    } else {
      name_splited[1]
    }
  })
}