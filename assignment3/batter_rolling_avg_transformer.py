import pyspark.sql.functions as pyspark_sql_function
from pyspark import keyword_only
from pyspark.ml import Transformer
from pyspark.ml.param.shared import HasInputCols, HasOutputCol
from pyspark.ml.util import DefaultParamsReadable, DefaultParamsWritable
from pyspark.sql.window import Window

# Refrences
# https://spark.apache.org/docs/2.4.0/api/python/pyspark.sql.html
# https://spark.apache.org/docs/2.4.0/api/python/pyspark.ml.html

# Declare class that will be used as transformer


class batter_rolling_avg_100_days(
    Transformer,
    HasInputCols,
    HasOutputCol,
    DefaultParamsReadable,
    DefaultParamsWritable,
):
    # Initialize
    @keyword_only
    def __init__(self, inputCols=None, outputCol=None):
        super(batter_rolling_avg_100_days, self).__init__()
        kwargs = self._input_kwargs
        self.setParams(**kwargs)
        return

    # Set params
    @keyword_only
    def setParams(self, inputCols=None, outputCol=None):
        kwargs = self._input_kwargs
        return self._set(**kwargs)

    # Calculate the Batting average using input columns and output column
    def _transform(self, dataset):
        input_cols = self.getInputCols()
        output_col = self.getOutputCol()

        # Assignment 2 comment:
        # If a batter doesn’t play for 5 years, and then decides to play
        # a game, your calculation will actually contain games from 5 years
        # ago, which is not a rolling 100 day average.
        #
        # For avoiding it, we calculate the days based on the number of seconds.
        def get_days_in_seconds(num_days):
            return num_days * 24 * 60 * 60

        # Using the windows function
        partition = (
            Window.partitionBy("batter")
            .orderBy(
                pyspark_sql_function.col("game_date").cast("timestamp").cast("long")
            )
            .rangeBetween(get_days_in_seconds(-101), get_days_in_seconds(-1))
        )
        # Create dataset to be returned
        dataset = (
            dataset.withColumn(
                "sum_hits", pyspark_sql_function.sum(input_cols[0]).over(partition)
            )
            .withColumn(
                "sum_atbats", pyspark_sql_function.sum(input_cols[1]).over(partition)
            )
            .withColumn(
                output_col,
                pyspark_sql_function.col("sum_hits")
                / pyspark_sql_function.col("sum_atbats"),
            )
        )

        return dataset
