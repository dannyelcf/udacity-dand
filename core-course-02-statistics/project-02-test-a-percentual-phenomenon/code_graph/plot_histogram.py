import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

NUM_BINS = 9
# file to read in
stroop_data = 'data/stroopdata.csv'
# pull data into NumPy dataframe
df = pd.read_csv(stroop_data)
# generates boxplot graph
ax = df.hist(bins=NUM_BINS, edgecolor='black', figsize=(20,6))
# customize graph
min_c = df['Congruent'].min()
max_c = df['Congruent'].max()
step_c = (max_c-min_c)/NUM_BINS
ax[0,0].set_xticks(np.arange(min_c, max_c+step_c, step_c))
ax[0,0].grid(b=False, axis='x')
ax[0,0].set_title('Congruent Task Histogram')
ax[0,0].set_xlabel('Time Spent (in seconds)')
ax[0,0].set_ylabel('Frequency')
min_i = df['Incongruent'].min()
max_i = df['Incongruent'].max()
step_i = (max_i-min_i)/NUM_BINS
ax[0,1].set_xticks(np.arange(min_i, max_i+step_i, step_i))
ax[0,1].grid(b=False, axis='x')
ax[0,1].set_title('Incongruent Task Histogram')
ax[0,1].set_xlabel('Time Spent (in seconds)')
ax[0,1].set_ylabel('Frequency')
# render it
plt.show()