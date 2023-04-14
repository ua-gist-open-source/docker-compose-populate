
FROM postgis/postgis:13-3.1 as builder
RUN apt update
RUN apt install -y postgis
RUN which shp2pgsql

FROM postgis/postgis:15-3.3

COPY --from=builder /usr/bin/shp2pgsql /usr/bin/shp2pgsql

RUN apt-get update && apt-get upgrade -y  && apt-get install -y vim jq unzip curl && apt-get autoremove -y 

ENV STATE delaware
ENV DATABASE delaware
ENV DB_USER postgres
ENV DB_PASSWORD postgres
ENV DB_HOST postgis
ENV DB_PORT 5432

COPY scripts /app
RUN chmod 755 /app/*
ENV PATH=/app:$PATH

CMD ["bash"]
