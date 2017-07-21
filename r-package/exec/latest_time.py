import pandas as pd

if __name__ == '__main__':
    df = pd.read_csv("../data/PSYC_1x_3T2016/demographic_multiple_choice.csv")
    print(df["row_date"].max())