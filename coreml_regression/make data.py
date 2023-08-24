import pandas as pd 
import numpy as np 
data_input = []
data_sample = []
solutions = []
for i in range(1,1000,1):
    if(i%4==0):
        solutions.append(i)
        data_input.append(np.array(data_sample))
        data_sample = []
    else:
        data_sample.append(int(i))
df = {'data' : data_input, 'solution' : solutions}
df = pd.DataFrame(df)
df.to_csv("linear_regression.csv",index=False)