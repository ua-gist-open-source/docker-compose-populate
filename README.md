# docker-compose-populate
```
version=1.0
docker build . -t populate-geofabrik
```
To populate PostGIS with Iceland OSM data:
```
# Create a network
docker network create gist604b

# Run a postgis instance
# TODO: Add volume
docker run -e POSTGRES_PASSWORD=postgres -d postgis/postgis:15-3.3

docker run --network gist604b -e PGPASSWORD=postgres -e REGION=europe -e STATE=iceland -e DATABASE=iceland populate-geofabrik populate-postgis.sh
```

To populate Geoserver with layers for each of the OSM tables:
```
docker run --network gist604b -e PGPASSWORD=postgres -e REGION=europe -e STATE=iceland -e DATABASE=iceland populate-geofabrik populate-geoserver.sh
```
Or to do both:
```
docker run --network gist604b -e PGPASSWORD=postgres -e REGION=europe -e STATE=iceland populate-geofabrik populate-all.sh
```

dock