#!/bin/bash

if [[ -z $DB_HOST ]]
then
	echo "DB_HOST is required"
	exit 1
fi
if [[ -z $DB_USER ]]
then
	echo "DB_USER is required"
	exit 1
fi
if [[ -z $DB_PORT ]]
then
	echo "DB_PORT is required"
	exit 1
fi
if [[ -z $DATABASE ]]
then
	echo "DATABASE is required"
	exit 1
fi
if [[ -z $STATE ]]
then
	echo "STATE is required"
	exit 1
fi
curl http://download.geofabrik.de/north-america/us/${STATE}-latest-free.shp.zip -o ${STATE}-latest-free.shp.zip

# Unzip
unzip ${STATE}-latest-free.shp.zip

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DATABASE"
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DATABASE -c "CREATE EXTENSION postgis"
x=$(ls *.shp | cut -f6 -d/ | sed 's/gis_osm_//' | sed 's/_free_1.shp//' | awk '{ print "gis_osm_" $1 "_free_1.shp:" $1 }')
for ft in $x; do
  f=$(echo $ft | cut -f1 -d:)
  t=$(echo $ft | cut -f2 -d: | sed 's/natural/nature/g')
  shp2pgsql -s 4326 -c -g geom $f public.$t | psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DATABASE
done
