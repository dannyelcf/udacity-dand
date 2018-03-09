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

df_summary <- function(df, variable) {
  .df_summary(df, substitute(variable))
}

.df_summary <- function(df, variable) {
  variable <- eval(variable, df)
  
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

text_df_summary <- function(df_summary) {
  paste0("min: ", df_summary$min,
         "    1st qu.: ", df_summary$qu1,
         "    median: ", df_summary$median,
         "    mean: ", round(df_summary$mean,2),
         "    3rd qu.: ", df_summary$qu3,
         "    95 %: ", df_summary$pc95,
         "    max: ", df_summary$max)
}

plot_summary <- function(data, x, y = 0) {
  x_q <- substitute(x)
  df_summary <- .df_summary(data, x_q)
  
  list(
    # Summaries....
    # 1st quantile
    annotate("segment", 
             x = df_summary$qu1, 
             xend = df_summary$median, 
             y = y, yend = y, colour = "black", 
             size = .6, 
             arrow = arrow(ends="first", angle=90, length=unit(.15,"cm"))),
    # 2nd quantile (median)
    annotate("segment", 
             x = df_summary$median, 
             xend = df_summary$median, 
             y = y, yend = y, colour = "black", 
             size = 1.1, 
             arrow = arrow(ends="both", angle=90, length=unit(.15,"cm"))),
    # 3rd quantile
    annotate("segment", 
             x = df_summary$median, 
             xend = df_summary$qu3, 
             y = y, yend = y, colour = "black", 
             size = .6, 
             arrow = arrow(ends="last", angle=90, length=unit(.15,"cm"))),
    # Lower outlier limiar (1st qu. - IQR * 1.5)
    annotate("segment", 
             x = if(df_summary$qu1 - (df_summary$iqr * 1.5) < df_summary$min) {
               df_summary$min
             } else {
               df_summary$qu1 - (df_summary$iqr * 1.5)
             }, 
             xend = df_summary$qu1, 
             y = y, yend = y, colour = "black", 
             size = .2, linetype = 1,
             arrow = arrow(ends="first", angle=90, length=unit(.1,"cm"))),
    # Upper outlier limiar (3st qu. + IQR * 1.5)
    annotate("segment", 
             x = df_summary$qu3, 
             xend = if(df_summary$qu3 + (df_summary$iqr * 1.5) > df_summary$max) {
               df_summary$max
             } else {
               df_summary$qu3 + (df_summary$iqr * 1.5)
             }, 
             y = y, yend = y, colour = "black", 
             size = .2, linetype = 1,
             arrow = arrow(ends="last", angle=90, length=unit(.1,"cm"))),
    # Mean
    annotate("point", 
             x = df_summary$mean, y = y, 
             colour = "red", size = 1.2)
  )
}

plot_cumsummary <- function(data, x, y) {
  x_q <- substitute(x)
  x <- eval(x_q, data)
  
  if(is.null(x)) {
    stop("'x' argument can't be NULL")
  }
  
  y_q <- substitute(y)
  y <- eval(y_q, data)
  
  if(is.null(y)) {
    stop("'y' argument can't be NULL")
  }
  
  df_cumsummary <- data %>%
                    # Create cumulative summaries variables
                     mutate(cummean = sapply(seq_along(y), 
                                             function(n) {
                                               mean(y[1:n])
                                             }),
                            cummedian = sapply(seq_along(y),
                                               function(n) {
                                                 median(y[1:n])
                                               }),
                            cum1stqu = sapply(seq_along(y), 
                                              function(n) {
                                                quantile(y[1:n], probs = .25)
                                              }),
                            cum3rdqu = sapply(seq_along(y), 
                                              function(n) {
                                                quantile(score[1:n], probs = .75)
                                              }))
  df_summary <- .df_summary(data, y_q)
  df_summary$max.x <- max(x)
  
  list <- list(
    # Summary lines
    geom_line(data = df_cumsummary,
              mapping = aes_string(x = deparse(x_q), y = "cummedian"), 
              linetype = 2, color = "black"),
    geom_line(data = df_cumsummary,
              mapping = aes_string(x = deparse(x_q), y = "cum1stqu"), 
              linetype = 3, color = "black"),
    geom_line(data = df_cumsummary,
              mapping = aes_string(x = deparse(x_q), y = "cum3rdqu"), 
              linetype = 3, color = "black"),
    geom_line(data = df_cumsummary,
              mapping = aes_string(x = deparse(x_q), y = "cummean"), 
              linetype = 1, color = "red"),
    # Labels of summary lines
    geom_text(data = df_summary,
              mapping = aes_string(x = "max.x", y = "median", 
                                   label = deparse("median")),
              size = 3, vjust = .3, hjust = -.1),
    geom_text(data = df_summary,
              mapping = aes_string(x = "max.x", y = "qu1", 
                                   label = deparse("1st qu.")),
              size = 3, vjust = .3, hjust = -.1),
    geom_text(data = df_summary,
              mapping = aes_string(x = "max.x", y = "qu3", 
                                   label = deparse("3rd qu.")),
              size = 3, vjust = .3, hjust = -.1),
    geom_text(data = df_summary,
              mapping = aes_string(x = "max.x", y = "mean", 
                                   label = deparse("mean")),
              size = 3, vjust = .3, hjust = -.1, color = "red")
  )
}

add_label <- function(y) {
  geom_text(aes_string(label = deparse(y)), 
            vjust = -1, size = 3)
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