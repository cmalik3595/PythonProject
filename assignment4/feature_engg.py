import os
import os.path
import sys

import numpy as np
import pandas as pd


# TODO: Run with iris.data, diabetes.csv
def load_file():
    file_path = ""
    while not os.path.exists(file_path):
        file_path = input("\nEnter complete file path for the input:\n")

    # Confusion : For now read as csv. What if someone enters html or jason file ??
    # TODO : make this generic reader for all file types.
    data_frames = pd.read_csv(file_path)

    # Let's say this is csv file for now and read the column names
    # This will constiture the feature list
    column_names = data_frames.columns.values.tolist()
    print("\nColumn names:\n", column_names)

    response_feature = ""

    # Search for the response feature in the column list. Ask the user for the intended column
    # to be used as a response
    while response_feature not in column_names and len(response_feature) != 1:
        response_feature = input("\nEnter single response feature variable name:\n")
    else:
        pass

    prediction_variables = []
    is_predicted = False
    while prediction_variables not in column_names and is_predicted is False:
        prediction_variables = input(
            "\nEnter comma separated predictor variables:\n"
        ).split(", ")
        is_predicted = all(item in column_names for item in prediction_variables)
    else:
        pass

    return data_frames, response_feature, prediction_variables


def process_response(data_frames, response):
    pass


def main():
    # https://medium.com/@debanjana.bhattacharyya9818/numpy-random-seed-101-explained-2e96ee3fd90b
    # Seed the generator
    np.random.seed(seed=123)

    # Load the file and fetch response feature
    data_frames, response, predicts = load_file()

    # process response
    (
        response_column,
        response_type,
        response_mean,
        response_column_uncoded,
    ) = process_response(data_frames, response)
    return


if __name__ == "__main__":
    sys.exit(main())
