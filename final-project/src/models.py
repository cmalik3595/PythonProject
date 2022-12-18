"""
"""
# import statistics

import database
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from sklearn.ensemble import (
    AdaBoostClassifier,
    GradientBoostingClassifier,
    RandomForestClassifier,
)
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix

# from sklearn.metrics import auc, confusion_matrix, roc_curve
from sklearn.model_selection import TimeSeriesSplit
from sklearn.naive_bayes import GaussianNB
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import LinearSVC

TSS = TimeSeriesSplit(n_splits=10, max_train_size=None)

PIPELINES = [
    Pipeline(
        [
            ("scaler", StandardScaler()),
            (
                "LogisticRegression",
                LogisticRegression(
                    multi_class="multinomial",
                ),
            ),
        ],
    ),
    Pipeline(
        [
            ("scaler", StandardScaler()),
            ("LinearSVC", LinearSVC(max_iter=100000)),
        ],
    ),
    Pipeline(
        [
            ("scaler", StandardScaler()),
            ("GaussianNB", GaussianNB()),
        ],
    ),
    Pipeline(
        [
            ("scaler", StandardScaler()),
            ("RandomForestClassifier", RandomForestClassifier()),
        ],
    ),
    Pipeline(
        [
            ("scaler", StandardScaler()),
            ("GradientBoostingClassifier", GradientBoostingClassifier()),
        ],
    ),
    Pipeline(
        [
            ("scaler", StandardScaler()),
            ("AdaBoostClassifier", AdaBoostClassifier()),
        ],
    ),
]


def try_models(
    X_: pd.DataFrame,
    y: pd.Series,
    feature_sets,
    path,
    title,
) -> None:
    result_df = pd.DataFrame()
    for pass_, feature_set in enumerate(feature_sets):
        X = X_
        df = X[feature_set]
        df[y.name] = y
        df = df.dropna()
        X = df.drop(y.name, axis=1)

        results = dict()

        for pipeline in PIPELINES:
            name = pipeline.steps[-1][0]
            results[name] = dict()
            results[name]["scores"] = list()
            results[name]["prediction"] = list()
            results[name]["probs"] = list()
            results[name]["confusion"] = list()

            for _, split in enumerate(TSS.split(X)):
                train_index, test_index = split
                X_train, X_test = X.iloc[train_index], X.iloc[test_index]
                y_train, y_test = y.iloc[train_index], y.iloc[test_index]
                pipeline.fit(X_train, y_train)
                y_pred = pipeline.predict(X_test)
                results[name]["prediction"] += [y_pred]
                results[name]["scores"] += [pipeline.score(X_test, y_test)]
                if hasattr(pipeline, "predict_proba"):
                    results[name]["probs"] += [
                        pipeline.predict_proba(
                            X_test,
                        )[:, 1]
                    ]
                else:
                    results[name]["model_probs"] = None
                results[name]["confusion"] += [
                    confusion_matrix(y_test, y_pred),
                ]

        for model, model_dict in results.items():
            for run, score in enumerate(model_dict["scores"]):
                row = {
                    "model": model,
                    "feature_set": ", ".join(feature_set),
                    "score": score,
                }
                result_df = result_df.append(row, ignore_index=True)
                # Plot confusion matrix for each run
                # https://stackoverflow.com/questions/60860121
                labels = [0, 1]
                cm = model_dict["confusion"][run]
                data = go.Heatmap(z=cm, y=labels, x=labels, colorscale="BrBg")
                annotations = []
                for i, row in enumerate(cm):
                    for j, value in enumerate(row):
                        annotations.append(
                            {
                                "x": labels[i],
                                "y": labels[j],
                                "font": {"color": "black"},
                                "text": str(value),
                                "xref": "x1",
                                "yref": "y1",
                                "showarrow": False,
                            }
                        )
                layout = {
                    "title": f"CF for {model}, run {i}",
                    "xaxis": {"title": "Predicted value"},
                    "yaxis": {"title": "Real value"},
                    "annotations": annotations,
                }
                fig = go.Figure(
                    data=data,
                    layout=layout,
                )
                fig.write_html(f"{path}/plots/{pass_}_{model}_cm_{run}.html")

    fig = px.box(
        result_df,
        x="feature_set",
        y="score",
        color="model",
        title=f"Model scores from {title} features",
    )
    fig.add_shape(
        type="line",
        x0=0,
        y0=database.AVERAGE_WINS,
        x1=1,
        y1=database.AVERAGE_WINS,
        line={"color": "black"},
        xref="paper",
        yref="y",
    )
    fig.write_html(f"{path}/models.html")
    return


if __name__ == "__main__":
    pass
