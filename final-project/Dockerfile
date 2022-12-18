FROM ubuntu
FROM python:3.10.6
ENV APP_HOME /app
WORKDIR $APP_HOME
ENV PYTHONPATH /


RUN apt-get update \
    && apt-get install --no-install-recommends --yes \
        build-essential \
        python3 \
        python3-pip \
        python3-dev \
        python3-pymysql \
        mariadb-client \
        pv \
    && apt-get install wget libmariadb3 libmariadb-dev vim --yes \ 
    && rm -rf /var/lib/apt/lists/*

RUN wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup \
    && echo "367a80b01083c34899958cdd62525104a3de6069161d309039e84048d89ee98b  mariadb_repo_setup" | sha256sum -c - \
    && chmod +x mariadb_repo_setup \
    && ./mariadb_repo_setup --mariadb-server-version="mariadb-10.6" \
    && apt-get install libmariadb3 libmariadb-dev --yes


COPY ./requirements.txt .

RUN pip3 install --upgrade pip
RUN pip3 install pip-tools
RUN pip3 install --compile --no-cache-dir -r requirements.txt

COPY ./scripts /scripts
COPY ./sql /sql
COPY ./src .
RUN chmod -R +x /scripts

#CMD sh -x /scripts/run.sh
