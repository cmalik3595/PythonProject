"""
"""
from itertools import product
from typing import Dict, Tuple

import pandas as pd
import statsmodels.api
from scipy.stats import pearsonr
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler


def calculate_predictor_metrics(
    X: pd.DataFrame,
    X_bins: Dict[str, pd.DataFrame],
    y: pd.Series,
) -> pd.DataFrame:
    scores = pd.DataFrame()
    for _, x in X.items():
        p_value, t_value = calculate_logarithmic_regression(x, y)
        x_bin = X_bins[x.name]
        mean_squared_diff_sum = x_bin["mean_squared_diff"].sum()
        mean_squared_diff_sum_w = x_bin["mean_squared_diff_weighted"].sum()
        entry = {
            "name": x.name,
            "p_value": p_value,
            "t_value": t_value,
            "mean_squared_diff_sum": mean_squared_diff_sum,
            "mean_squared_diff_sum_weighted": mean_squared_diff_sum_w,
        }
        scores = scores.append(entry, ignore_index=True)
    scores["rfc_importance"] = calculate_rfc_importance(X, y)
    scores["score"] = calculate_metric_scores(scores)
    scores = scores.sort_values("score", ascending=False)
    return scores


def calculate_logarithmic_regression(
    x: pd.Series,
    y: pd.Series,
) -> Tuple[float, float]:
    df = x.to_frame().join(y)
    df = df.dropna()
    x = df[x.name]
    if (x == 0).all():
        return (None, None)
    y = df[y.name]
    p = statsmodels.api.add_constant(x)
    lrm = statsmodels.api.Logit(y, p)
    lrm_fit = lrm.fit()
    t_value = round(lrm_fit.tvalues[1], 6)
    p_value = "{:.6e}".format(lrm_fit.pvalues[1])
    return (p_value, t_value)


def calculate_rfc_importance(
    X: pd.DataFrame,
    y: pd.Series,
) -> pd.Series:
    df = X.join(y)
    df = df.dropna()
    X = df.drop(y.name, axis=1)
    y = df[y.name]
    stdslr = StandardScaler()
    stdslr.fit(X)
    X = stdslr.transform(X)
    rfr = RandomForestClassifier()
    model = rfr.fit(X, y)
    return model.feature_importances_


def calculate_metric_scores(
    scores: pd.DataFrame,
) -> pd.Series:
    # Scale each metric and average t, weighted difference, and rfc importance
    scaled = pd.DataFrame()
    scaled["t_value"] = scores["t_value"].abs() / scores["t_value"].abs().max()
    scaled["mean_squared_diff_sum_weighted"] = (
        scores["mean_squared_diff_sum_weighted"].abs()
        / scores["mean_squared_diff_sum_weighted"].abs().max()
    )
    scaled["rfc_importance"] = (
        scores["rfc_importance"].abs() / scores["rfc_importance"].abs().max()
    )
    score_series = scaled.mean(axis=1)
    return score_series


def calculate_correlations(
    X: pd.DataFrame,
) -> pd.DataFrame:
    corrs = pd.DataFrame()
    X = X.dropna()
    for c in product(X.columns, X.columns):
        x0 = X[c[0]]
        x1 = X[c[1]]
        pearson_coef, _ = pearsonr(x=x0, y=x1)
        corrs = corrs.append(
            other={
                "x0": c[0],
                "x1": c[1],
                "pearson_coef": pearson_coef,
                "abs_coef": abs(pearson_coef),
            },
            ignore_index=True,
        )
    corrs = corrs.sort_values(
        by="abs_coef",
        ascending=False,
    )
    return corrs


def rank_bf(
    X_bf: dict, X_corr: pd.DataFrame, corr_threshold: float = 0.2
) -> pd.DataFrame:
    ranks = pd.DataFrame()
    for key, df in X_bf.items():
        mean_squared_diff_sum = df["mean_squared_diff"].sum()
        mean_squared_diff_sum_w = df["mean_squared_diff_weighted"].sum()
        entry = {
            "x0": key[0],
            "x1": key[1],
            "mean_squared_diff_sum": mean_squared_diff_sum,
            "mean_squared_diff_sum_weighted": mean_squared_diff_sum_w,
        }
        ranks = ranks.append(entry, ignore_index=True)
    ranks = ranks.sort_values(
        "mean_squared_diff_sum_weighted",
        ascending=False,
    )
    return ranks
