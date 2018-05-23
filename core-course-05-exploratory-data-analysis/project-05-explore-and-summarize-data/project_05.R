DEFAULT_COLOR = "grey50"
DEFAULT_ALFA = .1

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

df_summary <- function(df, variable) {
  .df_summary(df, substitute(variable))
}

.df_summary <- function(df, variable_q) {
  variable_e <- eval(variable_q, df)

  data.frame(min = min(variable_e),
             qu1 = quantile(variable_e, probs = .25, names = FALSE),
             median = quantile(variable_e, probs = .5, names = FALSE),
             mean = mean(variable_e),
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
    geom_vline(xintercept = ymd("2013-01-01"), color = "grey", linetype = 3),
    geom_vline(xintercept = ymd("2014-01-01"), color = "grey", linetype = 3),
    geom_vline(xintercept = ymd("2015-01-01"), color = "grey", linetype = 3),
    geom_vline(xintercept = ymd("2016-01-01"), color = "grey", linetype = 3),
    geom_vline(xintercept = ymd("2017-01-01"), color = "grey", linetype = 3),
    geom_vline(xintercept = ymd("2018-01-01"), color = "grey", linetype = 3)
  )
}

plot_x_summary <- function(data, x) {
  .plot_x_summary(data, substitute(x))
}

.plot_x_summary <- function(data, x_q) {
  #x_q <- substitute(x)
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
    geom_vline(xintercept = df_summary$mean, linetype = 1, color = "red")
  )
}

plot_y_summary <- function(data, y) {
  .plot_y_summary(data, substitute(y))
}

.plot_y_summary <- function(data, y_q) {
  #y_q <- substitute(y)
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
    geom_hline(yintercept = df_summary$mean, linetype = 1, color = "red")
  )
}

plot_cumsummary <- function(data, x, y) {
  .plot_cumsummary(data, substitute(x), substitute(y))
}

.plot_cumsummary <- function(data, x_q, y_q) {
  #x_q <- substitute(x)
  x <- eval(x_q, data)

  if(is.null(x)) {
    stop("'x' argument can't be NULL")
  }

  #y_q <- substitute(y)
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
              linetype = 1, color = "red", inherit.aes = FALSE)
  )
}

plot_frequency <- function(data,
                           x,
                           title,
                           label.x,
                           reorder.x = TRUE,
                           label.y = "Frequency",
                           axis.text.x = NULL,
                           subtitle_complement = NULL,
                           breaks.y = waiver(),
                           breaks.2nd.y = waiver()) {
  x_q <- substitute(x)
  
  summ <- 
    data %>% 
      group_by_(x_q) %>% 
      summarise(frequency = n()) %>% 
      df_summary(frequency)
 
  df_score <- 
    data %>% 
      group_by_(x_q) %>% 
      summarise(score = n())
  
  percent_axis <- function() {
    ggplot2::sec_axis(trans = ~./nrow(data),
             breaks = breaks.2nd.y,
             labels = scales::percent)
  }
  
  if(reorder.x == TRUE) {
    aes_x <- paste0("reorder(", deparse(x_q), ", -score)")
  } else {
    aes_x <- deparse(x_q) 
  }
  
  plot_score <- 
    df_score %>% 
      ggplot(aes_string(x = aes_x, 
                        y = "score")) +
      geom_col(color = DEFAULT_COLOR, alpha = DEFAULT_ALFA) +
      .plot_y_summary(data, x_q) +
      scale_y_continuous(breaks = breaks.y,
                         sec.axis = percent_axis()) +
      labs(title = title,
           subtitle = subtitle(nrow(data),
                               subtitle_complement,
                               summ),
           x = label.x,
           y = label.y)
  
  if(!is.null(axis.text.x)) {
    plot_score <- plot_score + theme(axis.text.x = axis.text.x)
  } 
  
  return(plot_score)
}

plot_distribution <- function(data,
                              x,
                              binwidth,
                              title,
                              label.x,
                              label.y = "Frequency",
                              subtitle_complement = NULL,
                              breaks.x = waiver(),
                              limits.x = NULL,
                              coord.xlim = NULL,
                              breaks.y = waiver(),
                              limits.y = NULL,
                              coord.ylim = NULL) {
  x_q <- substitute(x)
  summ <- .df_summary(data, x_q)
  
  # padding at the end
  if(!is.null(breaks.x) & is.null(limits.x) & is.null(coord.xlim)) {
    limits.x <- c(min(breaks.x), max(breaks.x))
  }
  
  plot_distribution <-
    data %>% 
    ggplot(aes_string(x = deparse(x_q))) +
    geom_histogram(binwidth = binwidth, color = DEFAULT_COLOR, alpha = DEFAULT_ALFA, 
                   boundary = summ$min, 
                   closed = "left") +
    .plot_x_summary(data, x_q) +
    scale_x_continuous(limits = limits.x, breaks = breaks.x) +
    scale_y_continuous(limits = limits.y, breaks = breaks.y) +
    coord_cartesian(xlim = coord.xlim, ylim = coord.ylim) +
    labs(title = title,
         subtitle = subtitle(nrow(data),
                             subtitle_complement,
                             summ),
         x = label.x,
         y = label.y) 
  
  return(plot_distribution)
}

plot_ts <- function(data,
                    x,
                    title,
                    label.x,
                    label.y,
                    subtitle_complement = NULL,
                    date_breaks.x = waiver(),
                    date_labels.x = waiver(),
                    date_expand.x = c(0.01, 0),
                    axis.text.x = NULL,
                    breaks.y = waiver()) {
  x_q <- substitute(x)
  
  df_score <- 
    data %>% 
    group_by_(x_q) %>% 
    summarise(score = n())
  
  plot_ts <-
    df_score %>% 
    ggplot(aes_string(x = deparse(x_q), y = "score")) +
    geom_area(color = DEFAULT_COLOR, alpha = DEFAULT_ALFA) +
    geom_point(color = DEFAULT_COLOR) +
    plot_year_vline() +
    .plot_cumsummary(df_score, 
                     x_q = x_q,
                     y_q = substitute(score)) +
    scale_x_date(date_breaks = date_breaks.x, date_labels = date_labels.x,
                 expand = date_expand.x) +
    scale_y_continuous(breaks = breaks.y) +
    labs(title = title,
         subtitle = subtitle(nrow(data)),
         x = label.x,
         y = label.y) +
    theme(axis.text.x = axis.text.x) 
  
  plot_ts
}

plot_cumulative_ts <- function(data,
                               x,
                               title,
                               label.x,
                               label.y,
                               subtitle_complement = NULL,
                               date_breaks.x = waiver(),
                               date_labels.x = waiver(),
                               date_expand.x = c(0.02, 0),
                               axis.text.x = NULL,
                               coord.xlim = NULL,
                               breaks.y = waiver(),
                               limits.y = NULL,
                               coord.ylim = NULL,
                               breaks.2nd.y = waiver()) {
  x_q <- substitute(x)
  
  df_score <- 
    data %>% 
    group_by_(x_q) %>% 
    summarise(score = n())
    
  df_cum_score <- 
    df_score %>%
    mutate(cumscore = cumsum(score))
  
  percent_axis <- function() {
    ggplot2::sec_axis(trans = ~./nrow(data),
                      breaks = breaks.2nd.y,
                      labels = scales::percent)
  }
  
  plot_cumulative_ts <-
    df_cum_score %>% 
    ggplot(aes_string(x = deparse(x_q), y = "cumscore")) +
    geom_area(color = DEFAULT_COLOR, alpha = DEFAULT_ALFA) +
    geom_point(color = DEFAULT_COLOR) +
    plot_year_vline() +
    geom_smooth(method = "lm", size = .5, fill = "blue", alpha = .2) +
    scale_x_date(date_breaks = date_breaks.x, date_labels = date_labels.x,
                 expand = date_expand.x) +
    scale_y_continuous(breaks = breaks.y,
                       sec.axis = percent_axis()) +
    coord_cartesian(xlim = coord.xlim, ylim = coord.ylim) +
    labs(title = title,
         subtitle = subtitle(nrow(data)),
         x = label.x,
         y = label.y) +
    theme(axis.text.x = axis.text.x) 
  
  return(plot_cumulative_ts)
}

plot_sankey <- function(data,
                        x,
                        stratum, 
                        alluvium,
                        title,
                        legend,
                        label.x,
                        weight = NULL,
                        label.y = "Frequency",
                        axis.text.x = NULL,
                        subtitle_complement = NULL,
                        breaks.y = waiver()) {
  x_q <- substitute(x)
  stratum_q <- substitute(stratum)
  alluvium_q <- substitute(alluvium)
  weight_q <- substitute(weight)
  
  plot_sankey <-
    ggplot(data,
           aes_string(x = deparse(x_q), stratum = deparse(stratum_q), 
                      weight = deparse(weight_q),
                      alluvium = deparse(alluvium_q), fill = deparse(stratum_q), 
                      label = deparse(stratum_q))) +
      scale_x_discrete(expand = c(.05, .05)) +
      scale_y_continuous(breaks = breaks.y) +
      geom_flow(alpha = .35, knot.pos = .04) +
      geom_stratum(alpha = .5, color = DEFAULT_COLOR) +
      guides(fill = guide_legend(title.position="top", legend, nrow = 2, byrow = TRUE)) + 
      labs(title = title,
           subtitle = subtitle(nrow(data), complement = subtitle_complement),
           x = label.x,
           y = label.y) +
      theme(legend.position = "bottom", legend.key.size = unit(.5, "line"))
  
  if(!is.null(axis.text.x)) {
    plot_sankey <- plot_sankey + theme(axis.text.x = axis.text.x)
  } 
  
  return(plot_sankey)
}
