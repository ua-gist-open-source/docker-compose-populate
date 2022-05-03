# docker-compose-populate
```
version=1.0
docker build . -t aaryno/populate-docker-webgis
docker push aaryno/populate-docker-webgis
```
To populate PostGIS with Iceland OSM data:
```
docker run --network gist604b -e REGION=europe -e STATE=iceland -e DATABASE=iceland aaryno/populate-docker-geo populate-postgis.sh
```
To populate Geoserver with layers for each of the OSM tables:
```
docker run --network gist604b -e REGION=europe -e STATE=iceland -e DATABASE=iceland aaryno/populate-docker-geo populate-geoserver.sh
```
Or to do both:
```
docker run --network gist604b -e REGION=europe -e STATE=iceland  aaryno/populate-docker-geo populate-all.sh
```
