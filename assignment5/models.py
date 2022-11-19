"""
"""
import statistics
import warnings

import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import KFold
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.svm import LinearSVC

warnings.simplefilter(action="ignore", category=FutureWarning)

KF = KFold(random_state=42, shuffle=True)


def build_models(X: pd.DataFrame, y: pd.Series) -> None:
    df = X
    df[y.name] = y
    df = df.dropna()
    X = df.drop(y.name, axis=1)
    svc_scores = []
    rfc_scores = []
    for i, split in enumerate(KF.split(X)):
        train_index, test_index = split
        X_train, X_test = X.iloc[train_index], X.iloc[test_index]
        y_train, y_test = y.iloc[train_index], y.iloc[test_index]
        svc = Pipeline(
            [
                ("scaler", StandardScaler()),
                ("svc", LinearSVC(max_iter=64000)),
            ]
        )
        svc.fit(X_train, y_train)
        svc_score = svc.score(X_test, y_test)
        svc_scores.append(svc_score)
        print(f"SVC {i:02}", round(svc_score, 2))

        rfc = Pipeline(
            [
                ("scaler", StandardScaler()),
                ("rfc", RandomForestClassifier()),
            ]
        )
        rfc.fit(X_train, y_train)
        rfc_score = rfc.score(X_test, y_test)
        rfc_scores.append(rfc_score)
        print(f"RFC {i:02}", round(rfc_score, 2))

    svc_avg = statistics.mean(svc_scores)
    rfc_avg = statistics.mean(rfc_scores)
    print(f"Avg. SVC score: {svc_avg:.2f}")
    print(f"Avg. RFC score: {rfc_avg:.2f}")
    return None


if __name__ == "__main__":
    pass
