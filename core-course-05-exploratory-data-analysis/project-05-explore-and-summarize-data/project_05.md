
# EDA in an Issue Tracking System Data Set

*by Dannyel Cardoso da Fonseca*

This project aims to explore a data set containing 22125 observations of
issues tracking and their history logs. The data set represents 5 years
of project management which aimed maintenance and customization of many
integrated systems ([SIG](https://docs.info.ufrn.br)) for the academic,
administrative and human resources management at the Universidade
Federal de Goiás ([UFG](https://www.ufg.br)).

A proprietary issue tracking system
([SIGProject](https://sigproject.esig.com.br)) was used to manage
activities of company ([ESIG](https://www.esig.com.br)) and client
([Cercomp](https://www.cercomp.ufg.br))
teams.

![Screenshot](project_05_files/screenshot-sigproject.esig.com.br-2018.02.25-11-25-48.png)

I used data wrangling techniques to export data from that and clean
them. The final data set, used in this project, and its documentation
can be accessed, respectively, in these links:

  - [Issues Data Set](issues_tracking.csv)
  - [Issues Data Set Documentation](issues_tracking.Rdoc.txt)

The exported data set, the wrangling process scripts and an example of
one issue tracking can be find in [data\_wrangling](data_wrangling)
folder.

# Data Set Summaries

In this section, I perform a univariate exploration in the data set, by
first examining the structure, followed by analysis of time-series
variables and ending with the analysis categorical and range variables.

### Data Set Structure

The issues data set contains 22125 rows and 24 variables. Of these 24
variables 16 are about issue data and 8 about issue’s logs.

    ## 'data.frame':    22125 obs. of  24 variables:
    ##  $ issue_id             : int  487247 487247 ...
    ##  $ issue_number         : int  88374 88374 ...
    ##  $ issue_title          : chr  "Tarefa 88374 - Alteração de Finan"| __truncated__ ...
    ##  $ issue_type           : Factor w/ 4 levels "CUSTOMIZATION",..: 1 1 ...
    ##  $ issue_creation_date  : POSIXct, format: "2016-12-15 15:07:32" ...
    ##  $ issue_system         : Factor w/ 10 levels "INDEFINIDO","SERVICOS INTEGRADOS",..: 4 4 ...
    ##  $ issue_start_date     : Date, format: "2016-12-20" ...
    ##  $ issue_subsystem      : Factor w/ 77 levels "ADMINISTRAÇÃO",..: 34 34 ...
    ##  $ issue_deadline_date  : Date, format: "2017-01-03" ...
    ##  $ issue_created_by     : chr  "HELENA CLAUDIA DOS SANTOS TEIXEIRA" ...
    ##  $ issue_stakeholder    : Factor w/ 2 levels "COMPANY","CUSTOMER": 1 1 ...
    ##  $ issue_status         : Factor w/ 10 levels "CANCELED","CUSTOMER CLOSING PENDING",..: 3 3 ...
    ##  $ issue_time_spent     : int  360 360 ...
    ##  $ issue_priority_number: int  999 999 ...
    ##  $ issue_progress       : int  100 100 ...
    ##  $ issue_priority_scale : Factor w/ 6 levels "SUSPENDED","LOW",..: 4 4 ...
    ##  $ log_build_info       : chr  NA ...
    ##  $ log_creation_date    : POSIXct, format: "2017-04-10 17:07:00" ...
    ##  $ log_action           : Factor w/ 14 levels "CHANGE OF RESPONSIBILITY",..: 5 12 ...
    ##  $ log_status           : Factor w/ 34 levels "AUTHORIZED DEVELOPMENT",..: 7 4 ...
    ##  $ log_progress         : int  100 100 ...
    ##  $ log_time_spent       : int  NA NA ...
    ##  $ log_created_by       : chr  "ROSANGELA DIVINA DE SOUSA SANTANA" ...
    ##  $ log_svn_revision     : int  NA NA ...

The number of distinct issues rows and issue’s logs rows are 4503 and
21978 respectively. That is, the number of issues represents 20% of the
data set and the number of logs represents 99% of it. The 1% of logs
remaining (147 rows) represents issues that do not have history logs.

The distribution and the summaries of number of logs per issue are
ploted in the histogram
below.

<img src="project_05_files/plots/Distribution of the Number of Logs per Issue-1.png" width="672" />

> **Note:** In the plot above, the black dashed lines represent the 1st
> and 3rd quartile, the black and red solid lines represent,
> respectivaly, median and mean and the black dotted line represent the
> upper threshold to the outliers (3rd qu. + 1.5 IQR).

Analysing the plot above, we can note that 90% of issues have up to 9
history logs, 75% of them have up to 6 history logs and 50% of issues
have between 2 and 6 logs, a narrow range. Despite the skewed shape of
plot, the median and mean are very close. This means that the amount of
ouliers (after 12 logs per issue) is low, approximately 4% of issues.

The representative narrow range of logs in an issue makes us think that
there shoud be an activity flow pattern to resolve an issue. This flow
pattern migth be observed in a commom sequence of log status. See more
informations in the [Log Status](#log-status) section.

The next 4 sections show the analisys of the temporal variables:
`issue_creation_date`, `issue_start_date`, `issue_deadline_date` and
`issue_time_spent`. In an issue tracking system, temporal variables is
the fundamental piece for monitoring and control of activities.

### Issue Creation Date

The data set analyzed comprises issues created in the period between
05/21/2013 and 01/26/2018. More precisaly, between 19:10:24 of
05/21/2013 and 16:16:06 of 01/26/2018.

To get a sense of how it was the demand throughout the project see the
plot below that shows the cumulated number of issues created along the
project and the trend line (in
blue).

<img src="project_05_files/plots/Cumulated Number of Issues Created-1.png" width="672" />

We note that the first 11 months (from May 2013 to March 2014) of the
project had very low demand, approximately 5% of the total. Some reasons
for this were:

  - The customer and company teams were small;
  - There were no defined work processes between customer and company;
  - That was the first time that the customer outsourced the development
    and deployment of systems;
  - The customer’s team had no experience with systems being deployed
    and the company’s team did not know the customer’s day-to-day
    business deeply.

The work processes and knowledge on both sides (customer and company)
were being built over those 11 months. The teams grew in size and new
modules started development and deployment. The next 12 months (from
April 2014 to March 2015) there was significant growth curve in the
activities, approximately 25% of growth over the previous 11 months.
From June 2015 the activities growth seems to stabilize, sometimes
taking small growth curves. In this period occurred approximately 65% of
project activities. Besides, the trend line fitted with growth curve
demonstrating that the project began to have a standardized behavior.

In the barplot below, we can see the project’s behavior in another way.
This plot shows the distribution of the number of issues created per
month and their cumulated
summaries.

<img src="project_05_files/plots/Distribution of the Number of Issues Created per Month-1.png" width="672" />

> **Note:** In the plot above, the black dashed lines represent the 1st
> and 3rd cumulated quartile, the black and red solid lines represent,
> respectivaly, cumulated median and mean.

Analysing the plot above, we note that the year 2013 had the lowest
demand. The accumulated mean variates between 10 and 20 issues per
month. At the end of 2013 and begin of 2014 there was a drop in
activities because of the low administrative and academic activities at
the university at the end of year. From April of 2014 until February of
2015 there was significant growth in activities. The cumulated mean
increases from 10 to 70 issues per month. The accumulated mean overcame
the cumulated median and the distance between cumulated 3rd quartile and
accumulated median became greater than distance between cumulated 1st
quartile and accumulated median. This means that these months had a high
number of issues created in relation to the past.

But from August of 2015 the pace of growth dropped. Now, we can note
that the distance between cumulated 1st quartile and cumulated median
becomes greater than distance between cumulated 3rd quartile and
cumulated median. This invertion provocated the overlap between
cumulated mean and median. The stabilization of the growth also
contributed to that. The average of growth pass to be only 10 monthly
issues from February 2015.

We also note that except the significant growth period (from April 2014
to February 2015) the months between September and December of each year
had a decline in activities. The reason is the low administrative and
academic activities at the university in this period. Thus, the demand
for customization and maintenance of the systems decreases.

During the week, the demand for new activities were concentrated on
business days (from Monday to Friday) as we can note in the barplot
below.

<img src="project_05_files/plots/Frequency of Issues Created per Weekday-1.png" width="672" />

> **Note:** In the plot above, the black dashed lines represent the 1st
> and 3rd quartile, the black and red solid lines represent,
> respectivaly, median and mean.

Note that whether we sort business days by the frequency of issues
creation we have Tue \> Wed \> Thu \> Fri \> Mon. Tuesday is the weekday
that has more issues creation (mode). Monday and Friday are the business
days with less issues creation. One of the reasons for this is that,
from April 2014, the work began to be planned by sprints. These sprints
were planned every Tuesday morning and issues were created in the
afternoon.

Issues created on weenkend (18 issues) may be considered outliers. These
are issues created on weekend shift that was done during the enrollment
periods. Theses outliers pull the mean and 1st quartile down. Removing
them, we have a new barplot. See the plot
below.

<img src="project_05_files/plots/Distribution of the Number of Issues Created per Weekday (No Weekend)-1.png" width="672" />

> **Note:** In the plot above, the black dashed lines represent the 1st
> and 3rd quartile, the black and red solid lines represent,
> respectivaly, median and mean.

Note that the summaries are now approximated. The median and mean
overlap and the distance between 1st and 3rd quartile became narrow.
These new summaries better reflect the behavior of issue creation.

Analysing how was the behaviour of the issues creation per hour of the
day we have the bimodal distribution
below.

<img src="project_05_files/plots/Distribution of the Number of Issues Created per Hour of the Day-1.png" width="672" />

> **Note:** In the plot above, the black dashed lines represent the 1st
> and 3rd quartile, the black and red solid lines represent,
> respectivaly, median and mean and the black dotted lines represent the
> lower and upper threshold to the outliers (lower = 1st qu. - 1.5 IQR,
> upper = 3rd qu. + 1.5 IQR).

The high volume of issue creation comprises between 8:00h and 18:00h,
office hours. The peak hours are around 10:00h and 15:00h. At lunch
time, the demand for new issues decreases. We note that this bimodal
distribution is quasi symmetrical. The 1st and 3rd quartiles match with
modes and the median and mean differ by a few minutes.

Ploting this distribution again but with only office hours (from 8:00h
to 18:00h) we have the same summaries of the distribution before. See
the plot
below.

<img src="project_05_files/plots/Distribution of the Number of Issues Created per Hour of the Day (Only Office Hours)-1.png" width="672" />

> **Note:** In the plot above, the black dashed lines represent the 1st
> and 3rd quartile, the black and red solid lines represent,
> respectivaly, median and mean.

This shows us that the high issue creation volume actually comprises
between 8:00h and
18:00h.

### Issue Start Date

…

<img src="project_05_files/plots/Distribution of the Number of Issues Started per Month-1.png" width="672" /><img src="project_05_files/plots/Distribution of the Number of Issues Started per Month-2.png" width="672" />

    ##   min qu1 median     mean qu3 iqr  pc90  max
    ## y   5 406    810 641.2857 921 515 993.6 1020

<img src="project_05_files/plots/Distribution of the Number of Issues Started per Weekday-1.png" width="672" />

### Issue Deadline Date

<img src="project_05_files/plots/Distribution of the Number of Issues Deadline per Month-1.png" width="672" /><img src="project_05_files/plots/Distribution of the Number of Issues Deadline per Month-2.png" width="672" />

    ##   min    qu1 median     mean   qu3   iqr  pc90 max
    ## y   1 258.75  282.5 250.6667 323.5 64.75 342.5 350

<img src="project_05_files/plots/Distribution of the Number of Issues Deadline per Weekday-1.png" width="672" />

### Issue Time Spent

    ##   min qu1 median     mean qu3 iqr pc90   max
    ## x   0   0    0.5 2.205639 2.1 2.1 5.58 107.4

<img src="project_05_files/plots/Distribution of the Number of Time Spent in a Issue per Hour-1.png" width="672" />

<img src="project_05_files/plots/Distribution of the Number of Time Spent in a Issue per Hour (Zoomed In)-1.png" width="672" />

    ##   min qu1 median     mean qu3 iqr pc90 max
    ## x   0   0      0 10.87472  18  18   36  54

<img src="project_05_files/plots/Distribution of the Number of Time Spent in a Issue (Less Than 1 Hour)-1.png" width="672" />

    ##   issue_time_spent score
    ## 1                0  1430
    ## 2                6   242
    ## 3               12   241
    ## 4               30   187
    ## 5               18   174

    ##   min qu1 median     mean qu3 iqr pc90 max
    ## x   6  12     18 23.29553  36  24   48  54

<img src="project_05_files/plots/Distribution of the Number of Time Spent in a Issue (Less Than 1 Hour and Non  0)-1.png" width="672" />

    ##   min qu1 median     mean qu3 iqr pc90   max
    ## x 0.1 0.5    1.3 3.232018 3.4 2.9 7.78 107.4

<img src="project_05_files/plots/Distribution of the Number of Time Spent in a Issue (Non 0)-1.png" width="672" />

### Issue Type

In the issue tracking system, 4 types of issues were used to classify
the purpose of a issue. They are:

    ## [1] "CUSTOMIZATION"  "DATA MIGRATION" "MAINTENANCE"    "OTHERS"

The frequency of issues created by each issue type is shown in the graph
below.

<img src="project_05_files/plots/Frequency of Issue Type-1.png" width="672" />

Analysing the plot above, we note that most of the issues are of the
MAINTENANCE type (around 75%). Next comes the issues of the
CUSTOMIZATION type (around 20%). And, with less than 0.05% comes the
issues of the types DATA MIGRATION and OTHERS. Thus, we can summarize
that project management was characterized by corrective maintenance
activities of existing systems and subsystems.

The demand for adaptation and evolution of the systems was not
insignificant. Although the amount of CUSTOMIZATION and DATA MIGRATION
issues are less than MAINTENANCE, they may have indirectly influenced in
the creation of large volume of MAINTENANCE issues. Maybe, CUSTOMIZATION
issues had provocated related creation of MAINTENANCE issues. The same
is true for DATA MIGRATION. An analysis of issues creation timeline by
system/subsystem may answer that
assumption.

### Issue System

<img src="project_05_files/plots/Frequency of Issue System-1.png" width="672" />

### Issue Subsystem

<img src="project_05_files/plots/Frequency of Issue Subsystem-1.png" width="672" />

### Issue Stakeholder

<img src="project_05_files/plots/Frequency of Issue Stakeholder-1.png" width="672" />

### Issue Created By

<img src="project_05_files/plots/Frequency of Issue Created By-1.png" width="672" />

### Issue Status

<img src="project_05_files/plots/Frequency of Issue Status-1.png" width="672" />

### Issue Priority Number

<img src="project_05_files/plots/Distribution of the Priority Number per Issue-1.png" width="672" />

    ##   issue_priority_number score
    ## 1                   999  2272
    ## 2                     0   427
    ## 3                     1   243
    ## 4                     2   192
    ## 5                     3   148

<img src="project_05_files/plots/Distribution of the Priority Number per Issue (Dropped 999 and Zoomed In to 100)-1.png" width="672" />

<img src="project_05_files/plots/Distribution of the Priority Number per Issue (Less than or Equal to 20)-1.png" width="672" />

### Issue Priority Scale

<img src="project_05_files/plots/Frequency of Issue Priority Scale-1.png" width="672" />

### Issue Progress

<img src="project_05_files/plots/Distribution of the Progress per Issue-1.png" width="672" />

    ##   issue_progress score
    ## 1            100  4492
    ## 2              0     8
    ## 3             50     1
    ## 4             60     1
    ## 5             90     1

### Log Build Info

<img src="project_05_files/plots/Distribution of the Number of the Issues per System's Version-1.png" width="672" />

<img src="project_05_files/plots/Distribution of the Number of the Issues per System's Version (Less Than 6 Issues)-1.png" width="672" />

### Log Status

> **Go back:** [Data Set Structure](#data-set-structure)

### Reflections on Data Set Summaries

What is the commom flow of the log states? (Data Set Structure)

What makes the demand low in 2013? What makes the demand grow rapidly in
2014?
