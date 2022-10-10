import sys

from batter_rolling_avg_transformer import batter_rolling_avg_100_days
from pyspark import StorageLevel
from pyspark.ml import Pipeline
from pyspark.sql import SparkSession

# Refrences
# https://spark.apache.org/docs/2.4.0/api/python/pyspark.sql.html
# https://spark.apache.org/docs/2.4.0/api/python/pyspark.ml.html
# https://www.educba.com/pyspark-persist/
# https://sparkbyexamples.com/spark/spark-dataframe-cache-and-persist-explained/
# https://umbertogriffo.gitbook.io/ \
#   apache-spark-best-practices-and-tuning/storage/which_storage_level_to_choose
# https://sparkbyexamples.com/spark/spark-createorreplacetempview-explained/

# Comment from Assignment 1 : No Globals


def main():

    # Set Spark environment
    spark = SparkSession.builder.master("local[*]").getOrCreate()

    # Connect to the db tables. Use UTC JDBCComplaint Time Zone shift so that the query doesn't complain of
    # unsupported timezone.
    http_url = "jdbc:mysql://localhost:3306/baseball?"
    args = "useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC"
    url = http_url + args

    # Put database credentials as spaces
    username = " "
    dbpass = " "

    # From Assignment 2
    # CREATE TABLE batter_game_actual_info
    #    AS
    #            SELECT
    #                    batters_info.game_id AS game_id,
    #                    batters_info.batter AS batter,
    #                    DATE_FORMAT(local_game.local_date,'%Y-%m-%d') as game_date,
    #                    DATE(DATE_SUB(local_game.local_date, INTERVAL 101 DAY)) AS 100_day_before_date,
    #                    batters_info.atBat,
    #                    batters_info.Hit
    #            FROM batter_counts batters_info
    #            INNER JOIN game local_game
    #                    ON batters_info.game_id = local_game.game_id
    #            WHERE batters_info.atBat > 0;

    # Create Mysql Queries
    game_table_query = """
            SELECT game_id,
            DATE(local_date) AS game_date
            FROM game
            """

    batter_query = """
            SELECT game_id,
            batter,
            Hit AS hits,
            atBat AS atbats
            FROM batter_counts WHERE atBat > 0
            """

    local_game = (
        spark.read.format("jdbc")
        .options(url=url, query=game_table_query, user=username, password=dbpass)
        .load()
    )

    batters_info = (
        spark.read.format("jdbc")
        .options(url=url, query=batter_query, user=username, password=dbpass)
        .load()
    )

    # Create temporary view for using the tables
    local_game.createOrReplaceTempView("local_game")
    batters_info.createOrReplaceTempView("batters_info")

    # Join tables
    batter_game_actual_info = batters_info.join(local_game, on=["game_id"], how="left")

    # Drop tables, persist joined table in memory
    local_game.unpersist()
    batters_info.unpersist()
    batter_game_actual_info.createOrReplaceTempView("batter_game_actual_info")

    # Store the RDD / Data frame into the JVM memory of the PySpark and if the space
    # exceeds memory, copy some frames to disk. The space is serialized
    # The tradeoff is that by using StorageLevel.MEMORY_AND_DISK , we avoid
    # costly delays associated with recomputations of data when memory is low.
    # Source :
    # https://umbertogriffo.gitbook.io/apache-spark-best-practices-and-tuning/storage/which_storage_level_to_choose
    batter_game_actual_info.persist(StorageLevel.MEMORY_AND_DISK)

    # Calculate the Rolling average using transformer
    # Give the column name as parameters
    batter_rolling_avg_transformer = batter_rolling_avg_100_days(
        inputCols=["hits", "atbats"], outputCol="rolling_avg_100_days"
    )

    # Use pipeline from our first assignment
    pipeline = Pipeline(stages=[batter_rolling_avg_transformer])
    model = pipeline.fit(batter_game_actual_info)
    batter_game_actual_info = model.transform(batter_game_actual_info)

    # Print
    batter_game_actual_info.show()
    return


if __name__ == "__main__":
    sys.exit(main())
