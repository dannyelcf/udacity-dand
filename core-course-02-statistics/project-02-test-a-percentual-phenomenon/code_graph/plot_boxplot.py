import pandas as pd
import matplotlib.pyplot as plt

# file to read in
stroop_data = 'data/stroopdata.csv'
# pull data into NumPy dataframe
df = pd.read_csv(stroop_data)
# generates boxplot graph
fig = plt.figure(figsize=(7, 5))
df.boxplot(showmeans=True, meanline=True)
# set up the graph
plt.title('Congruent and Incongruent Task Boxplot')
plt.xlabel('Task')
plt.ylabel('Time Spent (in seconds)')
# render it
plt.show()