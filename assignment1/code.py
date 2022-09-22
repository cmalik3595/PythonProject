import os.path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sb
from sklearn import metrics
from sklearn.datasets import load_iris
from sklearn.ensemble import (
    RandomForestClassifier,
    RandomForestRegressor,
    RandomTreesEmbedding,
)
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import r2_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

# Global data #
iris_data = pd.DataFrame()
local_iris_data = pd.DataFrame()
np_array = []
np_mean = []
np_min = []
np_max = []
np_quantile = []
column_names = ["SepalLenCm", "SepalWidthCm", "PetalLenCm", "PetalWidthCm", "Type"]

fp = ""
scatter_path = ""
box_path = ""
bar_path = ""
violin_path = ""
facet_path = ""
pair_path = ""
X_train = []
X_test = []
y_train = []
y_test = []
y = []
X = []


# Function to create generated_files directory
def create_generated_files_dir():
    global fp
    global scatter_path
    global box_path
    global bar_path
    global violin_path
    global facet_path
    global pair_path

    cur_working_dir = os.getcwd()
    fp = os.path.join(cur_working_dir, "../generated_files")
    if not os.path.exists(fp):
        os.mkdir(fp)

    scatter_path = os.path.join(fp, "scatterplot")
    if not os.path.exists(scatter_path):
        os.mkdir(scatter_path)

    box_path = os.path.join(fp, "boxplot")
    if not os.path.exists(box_path):
        os.mkdir(box_path)

    bar_path = os.path.join(fp, "bar")
    if not os.path.exists(bar_path):
        os.mkdir(bar_path)

    violin_path = os.path.join(fp, "violin")
    if not os.path.exists(violin_path):
        os.mkdir(violin_path)

    facet_path = os.path.join(fp, "facetgrid")
    if not os.path.exists(facet_path):
        os.mkdir(facet_path)

    pair_path = os.path.join(fp, "pair")
    if not os.path.exists(pair_path):
        os.mkdir(pair_path)


# Read the csv data into Pandas DataFrame object
def read_data():
    global iris_data
    iris_data = pd.read_csv("iris.data.csv", names=column_names)
    # Commented some useful functions
    # print(iris_data.head())
    # print(iris_data.describe())


# Convert pandas dataFrame object to numpy array
def convert_to_numpy():
    global np_array
    global local_iris_data

    # Copy to local data
    local_iris_data = iris_data.copy()

    # Drop the Type field from the local data
    local_iris_data.drop("Type", axis=1, inplace=True)

    # Rounding off decimals to 1 place
    local_iris_data.round(decimals=1).astype(float)

    # Identify any missing data
    local_iris_data.isnull().sum()

    # convert to numpy array
    np_array = local_iris_data.to_numpy()


# Display Numpy Array statistics
def disp_numpy_stats():
    global np_array
    global np_mean
    global np_min
    global np_max
    global np_quantile
    print("Mean : ", np_mean)
    print("Max  : ", np_max)
    print("Min  : ", np_min)

    # Display the Quantiles
    print("25% quantile: ", np.quantile(np_array, 0.25, axis=0))
    print("50% quantile: ", np.quantile(np_array, 0.50, axis=0))
    print("75% quantile: ", np.quantile(np_array, 0.75, axis=0))
    print("100% quantile: ", np.quantile(np_array, 0.1, axis=0))


# Numpy Array statistics
def numpy_stats():
    global np_array
    global np_mean
    global np_min
    global np_max
    global np_quantile

    # Calculate mean of all columns
    np_mean = np.mean(np_array, axis=0)
    # Calculate max of all columns
    np_max = np.max(np_array, axis=0)
    # Calculate min of all columns
    np_min = np.min(np_array, axis=0)

    # Display the numpy stats
    disp_numpy_stats()


# Plot
def plot_stats():
    global np_array
    global local_iris_data
    global iris_data
    global fp
    global scatter_path
    global box_path
    global bar_path
    global violin_path
    global facet_path
    global pair_path

    create_generated_files_dir()

    # Type 1 : Scatter
    iris_data.plot.scatter(x="SepalLenCm", y="SepalWidthCm", s=100, c="blue")
    fp1 = os.path.join(scatter_path, "SLenVsSWid")
    plt.savefig(fp1)

    iris_data.plot.scatter(x="SepalLenCm", y="PetalLenCm", s=100, c="blue")
    fp1 = os.path.join(scatter_path, "SLenVsPLen")
    plt.savefig(fp1)

    iris_data.plot.scatter(x="SepalLenCm", y="PetalWidthCm", s=100, c="blue")
    fp1 = os.path.join(scatter_path, "SLenVsPWid")
    plt.savefig(fp1)

    iris_data.plot.scatter(x="SepalWidthCm", y="PetalLenCm", s=100, c="blue")
    fp1 = os.path.join(scatter_path, "SWidVsPLen")
    plt.savefig(fp1)

    iris_data.plot.scatter(x="SepalWidthCm", y="PetalWidthCm", s=100, c="blue")
    fp1 = os.path.join(scatter_path, "SWidVsPWid")
    plt.savefig(fp1)

    # Type 2: Boxplot
    temp_data = iris_data[["SepalLenCm", "SepalWidthCm", "PetalLenCm", "PetalWidthCm"]]
    plt.figure(figsize=(10, 7))
    temp_data.boxplot()
    fp1 = os.path.join(box_path, "Boxplot")
    plt.savefig(fp1)

    sb.set(font_scale=1.6, rc={"figure.figsize": (12, 10)})
    sb.boxplot(x="Type", y="SepalLenCm", data=iris_data)
    sb.stripplot(
        x="Type", y="SepalLenCm", data=iris_data, jitter=True, edgecolor="gray", size=10
    )
    fp1 = os.path.join(box_path, "SepalLen")
    plt.savefig(fp1)

    sb.set(font_scale=1.6, rc={"figure.figsize": (12, 10)})
    sb.boxplot(x="Type", y="SepalWidthCm", data=iris_data)
    sb.stripplot(
        x="Type",
        y="SepalWidthCm",
        data=iris_data,
        jitter=True,
        edgecolor="gray",
        size=10,
    )
    fp1 = os.path.join(box_path, "SepalWid")
    plt.savefig(fp1)

    sb.set(font_scale=1.6, rc={"figure.figsize": (12, 10)})
    sb.boxplot(x="Type", y="PetalLenCm", data=iris_data)
    sb.stripplot(
        x="Type", y="PetalLenCm", data=iris_data, jitter=True, edgecolor="gray", size=10
    )
    fp1 = os.path.join(box_path, "PetallLen")
    plt.savefig(fp1)

    sb.set(font_scale=1.6, rc={"figure.figsize": (12, 10)})
    sb.boxplot(x="Type", y="PetalWidthCm", data=iris_data)
    sb.stripplot(
        x="Type",
        y="PetalWidthCm",
        data=iris_data,
        jitter=True,
        edgecolor="gray",
        size=10,
    )
    fp1 = os.path.join(box_path, "PetalWid")
    plt.savefig(fp1)

    # Type 3: Bar
    ax1 = local_iris_data.plot(kind="bar")
    x_axis = ax1.axes.get_xaxis()
    x_axis.set_visible(False)
    fp1 = os.path.join(bar_path, "Bar")
    plt.savefig(fp1)

    # Type 4: Bar-stacked
    ax1 = local_iris_data.plot(kind="bar", stacked=True)
    x_axis = ax1.axes.get_xaxis()
    x_axis.set_visible(False)
    fp1 = os.path.join(bar_path, "Bar-stacked")
    plt.savefig(fp1)

    # Type 5: violin
    sb.set(font_scale=1.8, rc={"figure.figsize": (12, 10)})
    sb.violinplot(x="Type", y="SepalLenCm", data=iris_data, size=6)
    sb.stripplot(
        x="Type", y="SepalLenCm", data=iris_data, jitter=True, edgecolor="gray", size=10
    )
    fp1 = os.path.join(violin_path, "SepalLen")
    plt.savefig(fp1)

    sb.set(font_scale=1.8, rc={"figure.figsize": (12, 10)})
    sb.violinplot(x="Type", y="SepalWidthCm", data=iris_data, size=6)
    sb.stripplot(
        x="Type",
        y="SepalWidthCm",
        data=iris_data,
        jitter=True,
        edgecolor="gray",
        size=10,
    )
    fp1 = os.path.join(violin_path, "SepalWid")
    plt.savefig(fp1)

    sb.set(font_scale=1.8, rc={"figure.figsize": (12, 10)})
    sb.violinplot(x="Type", y="PetalLenCm", data=iris_data, size=6)
    sb.stripplot(
        x="Type", y="PetalLenCm", data=iris_data, jitter=True, edgecolor="gray", size=10
    )
    fp1 = os.path.join(violin_path, "PetalLen")
    plt.savefig(fp1)

    sb.set(font_scale=1.8, rc={"figure.figsize": (12, 10)})
    sb.violinplot(x="Type", y="PetalWidthCm", data=iris_data, size=6)
    sb.stripplot(
        x="Type",
        y="PetalWidthCm",
        data=iris_data,
        jitter=True,
        edgecolor="gray",
        size=10,
    )
    fp1 = os.path.join(violin_path, "PetalWid")
    plt.savefig(fp1)

    # Type 6: FacetGrid single
    sb.FacetGrid(iris_data, hue="Type", height=9).map(
        sb.kdeplot, "SepalLenCm"
    ).add_legend()
    fp1 = os.path.join(facet_path, "SepalLen")
    plt.savefig(fp1)
    sb.FacetGrid(iris_data, hue="Type", height=9).map(
        sb.kdeplot, "SepalWidthCm"
    ).add_legend()
    fp1 = os.path.join(facet_path, "SepalWidth")
    plt.savefig(fp1)
    sb.FacetGrid(iris_data, hue="Type", height=9).map(
        sb.kdeplot, "PetalLenCm"
    ).add_legend()
    fp1 = os.path.join(facet_path, "PetalLen")
    plt.savefig(fp1)
    sb.FacetGrid(iris_data, hue="Type", height=9).map(
        sb.kdeplot, "PetalWidthCm"
    ).add_legend()
    fp1 = os.path.join(facet_path, "PetalWidth")
    plt.savefig(fp1)

    # Type 7: FacetGrid multiple
    sb.FacetGrid(iris_data, hue="Type", height=9).map(
        plt.scatter, "SepalLenCm", "SepalWidthCm"
    ).add_legend()
    fp1 = os.path.join(facet_path, "SLenVsSWid")
    plt.savefig(fp1)
    sb.FacetGrid(iris_data, hue="Type", height=9).map(
        plt.scatter, "SepalWidthCm", "PetalWidthCm"
    ).add_legend()
    fp1 = os.path.join(facet_path, "SWidVsPWid")
    plt.savefig(fp1)
    sb.FacetGrid(iris_data, hue="Type", height=9).map(
        plt.scatter, "SepalLenCm", "PetalLenCm"
    ).add_legend()
    fp1 = os.path.join(facet_path, "SLenVsPLen")
    plt.savefig(fp1)
    sb.FacetGrid(iris_data, hue="Type", height=9).map(
        plt.scatter, "PetalLenCm", "PetalWidthCm"
    ).add_legend()
    fp1 = os.path.join(facet_path, "PLenVsPWid")
    plt.savefig(fp1)

    # Type 8: PairPlot
    sb.pairplot(iris_data, hue="Type", height=9, diag_kind="kde")
    fp1 = os.path.join(pair_path, "PairPlot")
    plt.savefig(fp1)


# function for standard scaler operation
def model_standard_scaler():
    global iris_data
    global local_iris_data
    global X_train
    global X_test
    global y_train
    global y_test
    global y
    global X

    # In built function to load the Iris data and make an enumeration of 'Y' target values
    iris = load_iris()
    X = iris.data
    y = iris.target
    X_train = local_iris_data
    y_train = iris_data["Type"]

    # Split the data in 45-55 for training and testing purposes
    (X_train, X_test, y_train, y_test) = train_test_split(
        X, y, test_size=0.45, stratify=iris.target, random_state=123456
    )

    # Use Standard Scaler to convert the numeric array values to standardized values
    # Another option is to use minmaxscaler object
    std_scaler_object = StandardScaler()
    X_train = std_scaler_object.fit_transform(X_train)
    X_test = std_scaler_object.fit_transform(X_test)


def display_metrics(y_test, y_pred):
    # Calculate the score to find accuracy
    score = r2_score(y_test, y_pred)
    abs_err = metrics.mean_absolute_error(y_test, y_pred)
    sq_err = metrics.mean_squared_error(y_test, y_pred)
    rms_err = np.sqrt(metrics.mean_squared_error(y_test, y_pred))
    print(f"\tScore: {score:.5}")
    print(f"\tMean absolute error: {abs_err:.5}")
    print(f"\tMean square error: {sq_err:.5}")
    print(f"\tRoot mean square error:{rms_err:.5}")


# function for random forest classification
def fit_random_forest():
    global X_train
    global X_test
    global y_train
    global y_test

    # Add RandomForrest classifier object
    rf_classifier_object = RandomForestClassifier(
        n_estimators=100, oob_score=True, random_state=123456
    )
    rf_classifier_object.fit(X_train, y_train)
    y_pred = rf_classifier_object.predict(X_test)

    print("RandomForestClassifier Stats:")
    display_metrics(y_test, y_pred)
    return r2_score(y_test, y_pred)


def rfs_pipeline():
    global X_train
    global X_test
    global y_train
    global y_test

    rf_pipe = Pipeline(
        [
            ("scl", StandardScaler()),
            ("clf", RandomForestRegressor(n_estimators=50, min_samples_split=5)),
        ]
    )

    rf_pipe.fit(X_train, y_train)
    y_pred = rf_pipe.predict(X_test)

    print("PP(StdScaler + RandomForrestRegression):")
    display_metrics(y_test, y_pred)
    return r2_score(y_test, y_pred)


def cfs_pipeline():
    global X_train
    global X_test
    global y_train
    global y_test

    cf_pipe = Pipeline(
        [
            ("rge", RandomTreesEmbedding(n_estimators=10, max_depth=3, random_state=0)),
            ("lgs", LogisticRegression(max_iter=1000)),
        ]
    )
    cf_pipe.fit(X_train, y_train)
    y_pred = cf_pipe.predict(X_test)

    print("PP(RandomTreesEmbedding + LogisticRegression):")
    display_metrics(y_test, y_pred)
    return r2_score(y_test, y_pred)


# Defining main function
def main():
    read_data()
    convert_to_numpy()
    numpy_stats()
    plot_stats()
    model_standard_scaler()
    fit_random_forest()
    rfs_pipeline()
    cfs_pipeline()


# Using the special variable
# __name__
if __name__ == "__main__":
    main()
