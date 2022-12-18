import sys
import webbrowser

import bins
import database
import metrics
import models
import plot
import report


def report_bsrs() -> None:
    y = database.RESPONSE
    print(y)
    X = database.get_bsr_X()
    print(X)

    for _, x in X.items():
        figure = plot.plot_violin(x, y, "(Base Runs expectation stats)")
        plot.save_figure(
            figure,
            f"./output/reports/bsr/plots/{x.name}_feature_plot.html",
        )
    # Bin the responses into n=10 populations.
    X_bins = {x.name: bins.bin_predictor(x, y) for _, x in X.items()}
    print(f"{X_bins}\n")

    # Plot weighted and unweighted
    for _, x in X.items():
        figure = plot.plot_bins(x.name, y.name, X_bins[x.name])
        plot.save_figure(
            figure,
            f"./output/reports/bsr/plots/{x.name}_bin_plot.html",
        )

    # Calculate and score metrics for each predictor
    X_metrics = metrics.calculate_predictor_metrics(X, X_bins, y)
    print(f"{X_metrics}\n")

    # Report predictors
    report.report_predictors(
        X_metrics,
        "predictor_report.html",
        "./output/reports/bsr/",
    )

    # Open report's folder in browser
    webbrowser.open("output/reports/bsr/predictor_report.html", new=2)

    # Calculate correlations
    X_corrs = metrics.calculate_correlations(X)
    print(f"{X_corrs}\n")

    # Plot correlations
    figure = plot.plot_correlations(X_corrs)
    plot.save_figure(
        figure,
        "./output/reports/bsr/plots/corr_plot.html",
    )

    # Report correlations
    report.report_correlations(
        X_corrs,
        "corr_report.html",
        "./output/reports/bsr/",
    )

    webbrowser.open("output/reports/bsr/corr_report.html", new=2)

    # Calculate brute-force
    X_bf_bins = bins.bin_combinations(X, y, X_corrs, threshold=0.25)

    # Plot bfs
    for key, b in X_bf_bins.items():
        bf_path = "./output/reports/bsr/plots/"
        bf_path = bf_path + f"{key[0]}X{key[1]}_bf_plot.html"
        figure = plot.plot_bruteforce(b, key[0], key[1])
        plot.save_figure(
            figure,
            bf_path,
        )

    # Rank bfs
    X_bf_ranks = metrics.rank_bf(X_bf_bins, X_corrs)

    # Report bfs
    report.report_bruteforces(
        X_bf_ranks,
        "bf_report.html",
        "./output/reports/bsr/",
    )

    webbrowser.open("output/reports/bsr/bf_report.html", new=2)

    features0 = ["simple_ratio_roll160"]
    features1 = ["simple_ratio_roll10", "away_offshoot_career"]
    models.try_models(
        X,
        y,
        [
            features0,
            features1,
        ],
        "./output/reports/bsr/",
        "Base Runs (BsR)",
    )

    webbrowser.open("output/reports/bsr/models.html", new=2)


def main() -> int:
    report_bsrs()
    return 0


if __name__ == "__main__":
    sys.exit(main())
