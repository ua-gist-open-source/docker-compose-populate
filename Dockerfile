FROM mdillon/postgis

RUN apt-get update && apt-get upgrade -y && apt-get install -y vim jq unzip curl && apt-get autoremove -y 

ENV STATE hawaii
ENV DATABASE hawaii
ENV DB_USER postgres
ENV DB_HOST postgis
ENV DB_PORT 5432

ADD scripts /

RUN chmod 755 /populate_*
