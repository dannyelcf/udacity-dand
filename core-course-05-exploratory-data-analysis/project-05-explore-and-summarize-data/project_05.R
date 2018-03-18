load_packages <- function(packages) {
  sapply(packages,
         function(pkg) {
           tryCatch(library(pkg, character.only = TRUE, warn.conflicts = FALSE),
                    error = function(err) {
                      utils::install.packages(pkg, quiet = TRUE)
                      library(pkg, character.only = TRUE, warn.conflicts = FALSE)
                    })
         })
}

load_dataset <- function(path) {
  # Load the Issues Tracking Data Set
  setClass('date_ymd_hms')
  setAs("character","date_ymd_hms", function(from) ymd_hms(from))
  setClass('date_ymd')
  setAs("character", "date_ymd", function(from) ymd(from))
  # setClass('time_period')
  # setAs("character", "time_period", function(from) seconds_to_period(from))
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
                                    # "time_period", # issue_time_spent
                                    "integer", # issue_time_spent
                                    "integer", # issue_priority_number
                                    "integer", # issue_progress
                                    "factor_issue_priority_scale",  # issue_priority_scale
                                    "character", # log_build_info
                                    "date_ymd_hms",  # log_creation_date
                                    "factor", # log_action
                                    "factor", # log_status
                                    "integer", # log_progress
                                    # "time_period", # log_time_spent
                                    "integer", # log_time_spent
                                    "character", # log_created_by
                                    "integer" # log_svn_revision
                     ))
}

ci.mean <- function(vec) {
  if(length(vec) == 1) {
    df_ci <- data.frame(mean = vec[1],
                        se = 0,
                        low = vec[1],
                        high = vec[1])
    return(df_ci)
  }
  
  fun.mean <- function(vec, idx) {
    mean(vec[idx], na.rm = TRUE)
  }
  
  boot.mean <- boot(vec, fun.mean, R=5000)
  boot.ci.mean <- boot.ci(boot.mean, type = "perc")
  df_ci <- data.frame(mean = boot.mean$t0,
                      se = sd(boot.mean$t[,1]),
                      low = boot.ci.mean$percent[4],
                      high = boot.ci.mean$percent[5])
  return(df_ci)
}

df_summary <- function(df, variable) {
  .df_summary(df, substitute(variable))
}

.df_summary <- function(df, variable) {
  variable_e <- eval(variable, df)
  ci.mean <- ci.mean(variable_e)

  data.frame(min = min(variable_e),
             qu1 = quantile(variable_e, probs = .25, names = FALSE),
             median = quantile(variable_e, probs = .5, names = FALSE),
             mean = mean(variable_e),
             mean.ci.low = ci.mean$low,
             mean.ci.high = ci.mean$high,
             mean.se = ci.mean$se,
             sd = sd(variable_e),
             qu3 = quantile(variable_e, probs = .75, names = FALSE),
             iqr = (quantile(variable_e, probs = .75, names = FALSE) -
                      quantile(variable_e, probs = .25, names = FALSE)),
             max = max(variable_e))

}

text_df_summary <- function(df_summary) {
  paste0("min: ", round(df_summary$min, 1),
         "    1st qu.: ", round(df_summary$qu1, 1),
         "    median: ", round(df_summary$median, 1),
         "    mean: ", round(df_summary$mean, 1),
         "    sd: ", round(df_summary$sd, 1),
         "    3rd qu.: ", round(df_summary$qu3, 1),
         "    max: ", round(df_summary$max, 1))
}

subtitle <- function(observations, complement = NULL, df_summary = NULL) {
  paste0(observations,
         " observations ",
         complement,
         if(!is.null(df_summary)) {
           paste0("\n", text_df_summary(df_summary))
         } else {
           NULL
         })
}

plot_year_vline <- function() {
  list(
    geom_vline(xintercept = ymd("2013-01-01"), color = "grey50"),
    geom_vline(xintercept = ymd("2014-01-01"), color = "grey50"),
    geom_vline(xintercept = ymd("2015-01-01"), color = "grey50"),
    geom_vline(xintercept = ymd("2016-01-01"), color = "grey50"),
    geom_vline(xintercept = ymd("2017-01-01"), color = "grey50"),
    geom_vline(xintercept = ymd("2018-01-01"), color = "grey50")
  )
}

plot_x_summary <- function(data, x) {
  x_q <- substitute(x)
  df_summary <- .df_summary(data, x_q)

  list(
    # Summaries....
    # 1st quantile
    geom_vline(xintercept = df_summary$qu1, linetype = 2, color = "black"),
    # 2nd quantile (median)
    geom_vline(xintercept = df_summary$median, linetype = 1, color = "black"),
    # 3rd quantile
    geom_vline(xintercept = df_summary$qu3, linetype = 2, color = "black"),
    # Lower outlier limiar (1st qu. - IQR * 1.5)
    if(df_summary$qu1 - (df_summary$iqr * 1.5) > df_summary$min) {
      geom_vline(xintercept = df_summary$qu1 - (df_summary$iqr * 1.5),
                 linetype = 3, color = "black")
    } else {
      geom_blank()
    },
    # Upper outlier limiar (3st qu. + IQR * 1.5)
    if(df_summary$qu3 + (df_summary$iqr * 1.5) < df_summary$max) {
      geom_vline(xintercept = df_summary$qu3 + (df_summary$iqr * 1.5),
                 linetype = 3, color = "black")
    } else {
      geom_blank()
    },
    # Mean
    geom_vline(xintercept = df_summary$mean, linetype = 1, color = "red"),
    annotate("rect", 
             xmin = df_summary$mean.ci.low,
             xmax = df_summary$mean.ci.high,
             ymin = -Inf,
             ymax = Inf,
             fill = "red", alpha = .2)
  )
}

plot_y_summary <- function(data, y) {
  y_q <- substitute(y)
  df_summary <- data %>%
                  group_by_(y_q) %>%
                  summarise(frequency = n()) %>%
                  df_summary(frequency)

  list(
    # Summaries....
    # 1st quantile
    geom_hline(yintercept = df_summary$qu1, linetype = 2, color = "black"),
    # 2nd quantile (median)
    geom_hline(yintercept = df_summary$median, linetype = 1, color = "black"),
    # 3rd quantile
    geom_hline(yintercept = df_summary$qu3, linetype = 2, color = "black"),
    # Lower outlier limiar (1st qu. - IQR * 1.5)
    if(df_summary$qu1 - (df_summary$iqr * 1.5) > df_summary$min) {
      geom_hline(yintercept = df_summary$qu1 - (df_summary$iqr * 1.5),
                 linetype = 3, color = "black")
    } else {
      geom_blank()
    },
    # Upper outlier limiar (3st qu. + IQR * 1.5)
    if(df_summary$qu3 + (df_summary$iqr * 1.5) < df_summary$max) {
      geom_hline(yintercept = df_summary$qu3 + (df_summary$iqr * 1.5),
                 linetype = 3, color = "black")
    } else {
      geom_blank()
    },
    # Mean
    geom_hline(yintercept = df_summary$mean, linetype = 1, color = "red"),
    annotate("rect", 
             xmin = -Inf,
             xmax = Inf,
             ymin = df_summary$mean.ci.low,
             ymax = df_summary$mean.ci.high,
             fill = "red", alpha = .2)
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
  
  #https://stackoverflow.com/a/32833744/8645131
  cummean.ci <- lapply(seq_along(y),
                       function(n) {
                         ci.mean(y[1:n])
                       })
  cummean.ci <- do.call(rbind, cummean.ci)
  
  df_cumsummary <- data %>%
                     # Create cumulative summaries variables
                     mutate(cummean = sapply(seq_along(y),
                                             function(n) {
                                               mean(y[1:n])
                                             }),
                            cummean.low = cummean.ci$low,
                            cummean.high = cummean.ci$high,
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
                                              })) %>% 
                      mutate()

  list <- list(
    # Summary lines
    geom_line(data = df_cumsummary,
              mapping = aes_string(x = deparse(x_q), y = "cummedian"),
              linetype = 1, color = "black", inherit.aes = FALSE),
    geom_line(data = df_cumsummary,
              mapping = aes_string(x = deparse(x_q), y = "cum1stqu"),
              linetype = 2, color = "black", inherit.aes = FALSE),
    geom_line(data = df_cumsummary,
              mapping = aes_string(x = deparse(x_q), y = "cum3rdqu"),
              linetype = 2, color = "black", inherit.aes = FALSE),
    geom_line(data = df_cumsummary,
              mapping = aes_string(x = deparse(x_q), y = "cummean"),
              linetype = 1, color = "red", inherit.aes = FALSE),
    geom_ribbon(data = df_cumsummary,
                aes_string(x = deparse(x_q), 
                           ymin = "cummean.low", ymax = "cummean.high"), 
                fill = "red", alpha = .2, inherit.aes = FALSE)
  )
}

# count_weekend_days = function(start_date, end_date) {
#   count <- vector("integer", length(start_date))
# 
#   for(i in seq_along(start_date)) {
#     start <- as.Date(start_date[i])
#     end <- as.Date(end_date[i])
#     if (start < end) {
#       vector_with_days = strftime(seq(start, end, by = 1), '%A')
#       count[i] <- -sum(vector_with_days %in% c('Saturday', 'Sunday'))
#     } else {
#       vector_with_days = strftime(seq(end, start, by = 1), '%A')
#       count[i] <- sum(vector_with_days %in% c('Saturday', 'Sunday'))
#     }
#   }
# 
#   return(count)
# }

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
