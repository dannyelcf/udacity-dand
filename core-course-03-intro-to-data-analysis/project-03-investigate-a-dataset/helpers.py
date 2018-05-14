#coding: utf-8
"""
This module contains functions to help with statistical calculations and plotting using the Matplotlib library.
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

#
# Util
#

def group_survived(data, by=None, apply='count', on='PassengerId'):
    """
    It aggregates the Survived column and 'by' param applying 'apply' function.
    """
    if by == None:
        data_view = data[['Survived', on]]
        grouped_df = data_view.groupby(['Survived'])
        grouped_df = grouped_df.agg(apply)
        if type(grouped_df.index) == pd.MultiIndex:
            grouped_df = grouped_df.unstack(1)
        grouped_df = grouped_df.reindex(index=['Yes', 'No'])
    else:
        data_view = data[['Survived', on, by]]
        grouped_df = data_view.groupby(['Survived', by])
        grouped_df = grouped_df.agg(apply)
        grouped_df = grouped_df.unstack(by)
        grouped_df = grouped_df[on]
        grouped_df = grouped_df.reindex(index=['Yes', 'No'])
    return grouped_df

def show_margin(data, margin_name='All', axis='both'):
    """
    It sums the values of index and columns axis and inserts the respective totals 
    in a new index and new column which name is margin_name param.
    """
    if axis == 'both':
        new_df = data.copy()
        new_df.loc[margin_name] = new_df.sum() # add row
        new_df.loc[:, margin_name] = new_df.sum(axis='columns') # add column
    elif axis == 'index':
        new_df = data.copy()
        new_df.loc[:, margin_name] = new_df.sum(axis='columns') # add column
    elif axis == 'columns':
        new_df = data.copy()
        new_df.loc[margin_name] = new_df.sum() # add row
    else:
        raise ValueError("Param 'axis' must be either 'index', 'columns' or 'both'")
    return new_df

#
# Statistic
#

def missing_values(data):
    """
    Calculates the percentage of missing values for each dataset column.
    """
    mis_val = data.isnull().sum()
    mis_val_percent = (100 * mis_val / len(data)).round(2)
    new_df = pd.DataFrame(mis_val_percent).rename(columns={0: 'Missing Values (%)'})
    return new_df.T

def frequency(data, axis='index'):
    """
    Calculates the relative frequency (proportion) of a dataframe.
    """
    if axis == 'columns':
        sum_col = data.sum(axis='columns')
        new_data = data.div(sum_col, axis='index')   
    elif axis == 'index':
        sum_idx = data.sum(axis='index')
        total_df = pd.DataFrame(sum_idx).T
        new_df = pd.DataFrame()
        for idx in data.index:
            new_row = total_df.rename(index={0: idx})
            new_df = new_df.append(new_row)
        new_data = data.div(new_df, axis='columns')
    else:
        raise ValueError("Param 'axis' must be either 'index' or 'columns'")
    return new_data

def expected_value(data):
    """
    Calculates the expected value to be used in calculation of chi square.
    """
    data_with_margin = show_margin(data, margin_name='All') 
    row_margin = data_with_margin.loc['All':,]
    col_margin = data_with_margin.loc[:,'All']
    cell_all_all = data_with_margin.get_value('All','All')
    
    new_df = pd.DataFrame()
    new_df.index.name = data.index.name
    new_df.columns.name = data.columns.name
    for idx in data.index:
        for col in data.columns:
            col_value = row_margin.get_value('All', col)
            row_value = col_margin[idx]
            cell = (col_value * row_value) / float(cell_all_all)
            new_df.set_value(idx, col, cell)

    return new_df

def chi_square(observed_data, expected_data):
    """
    Calculates the chi square.
    """
    diff = observed_data - expected_data
    diff_squared = diff ** 2
    ratio = diff_squared / expected_data
    values = ratio.values
    return np.sum(values)

def cramersV(data):
    """
    Calculates the effect size Cramér's V.
    """
    num_rows = len(data.index)
    num_cols = len(data.columns)
    df = min(num_rows - 1, num_cols - 1)
    total = show_margin(data).get_value('All','All')
    chi = chi_square(data, expected_value(data))
    
    return np.sqrt(chi / (total * df))

#
# Ploting
#

def survivor_plot_bar(data):
    """
    Plot a horizontal stacked bar chart grouped by Survided column
    """
    data.T.plot.barh(stacked=True, color=['#74c476', '#ff6464'], figsize=(6, 3))
    plt.legend(title='Survided', labels=data.index, bbox_to_anchor=(1.3, 1))

def survived_plot_pie(data):
    """
    Plot a pie chart grouped by Survided column
    """
    data.plot.pie('PassengerId',
                  autopct='%.1f%%',
                  pctdistance=0.5,
                  startangle=90,
                  colors=['#74c476', '#ff6464'],
                  labels=['', ''],
                  figsize=(3.5, 3.5))
    plt.legend(title='Survided', labels=data.index, bbox_to_anchor=(1.3, 1))

def survived_plot_hist(data, bins=20):
    """
    Plot a histogram chart grouped by Survided column
    """
    grid = sns.FacetGrid(data, col=data.columns[0])
    grid = grid.map(plt.hist, data.columns[1], bins=bins)
    grid.set_ylabels('Frequency')

def survived_plot_box(data):
    """
    Plot a boxplot chart grouped by Survided column
    """
    plt.figure(figsize=(6,3))
    sns.boxplot(data=data[['Survived', 'Age']], x=data.columns[0], y=data.columns[1])
