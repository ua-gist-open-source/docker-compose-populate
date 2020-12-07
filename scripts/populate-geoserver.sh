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
if [[ -z $DB_PASSWORD ]]
then
    echo "DB_USER is required"
    exit 1
fi
if [[ -z $DB_PASSWORD ]]
then
    echo "DB_PORT is required"
    exit 1
fi
if [[ -z $DATABASE ]]
then
    echo "DATABASE is required"
    exit 1
fi


# CREATE WORKSPACE
curl -v -u admin:geoserver -H "Content-type: application/json" -XPOST http://geoserver:8080/geoserver/rest/workspaces -d '
{
  "workspace" : {
    "name": "osm"
  }
}'

# CREATE DATASTORE
curl -v -u admin:geoserver -H 'Content-type: application/json' -XPOST http://geoserver:8080/geoserver/rest/workspaces/osm/datastores -d '
{
  "dataStore": {
    "name": "osm",
    "connectionParameters": {
      "entry": [
        {"@key":"host","$":"'${DB_HOST}'"},
        {"@key":"port","$":"'${DB_PORT}'"},
        {"@key":"database","$":"'${DATABASE}'"},
        {"@key":"user","$":"'${DB_USER}'"},
        {"@key":"passwd","$":"'${DB_PASSWORD}'"},
        {"@key":"dbtype","$":"postgis"}
      ]
    }
  }
}'


TABLES=$(psql -t -U $DB_USER -d $DATABASE -h $DB_HOST -c "select t.table_name from information_schema.tables t where t.table_schema='public' and t.table_type='BASE TABLE' and table_name<>'spatial_ref_sys' order by t.table_name;")

for TABLE in $TABLES; do
    BOX=$(psql -t -U postgres -d $DATABASE -h postgis -c "select st_asgeojson(st_extent(geom)) from $TABLE;" | jq '.')
    MINX=$(echo $BOX | jq '.coordinates[0][0][0]')
    MINY=$(echo $BOX | jq '.coordinates[0][0][1]')
    MAXX=$(echo $BOX | jq '.coordinates[0][2][0]')
    MAXY=$(echo $BOX | jq '.coordinates[0][2][1]')

    curl -v -u admin:geoserver -H 'Content-type: application/json' -XPOST http://geoserver:8080/geoserver/rest/workspaces/osm/datastores/osm/featuretypes/ -d '{
  "featureType": {
    "name": "'$TABLE'",
    "nativeName": "'$TABLE'",
    "namespace": {
      "name": "osm",
      "href": "http://geoserver:8080/geoserver/rest/namespaces/osm.json"
    },
    "title": "'${TABLE}'",
    "nativeCRS": "EPSG:4326",
    "srs": "EPSG:4326",
    "nativeBoundingBox": {
      "minx": '$MINX',
      "maxx": '$MAXX',
      "miny": '$MINY',
      "maxy": '$MAXY',
      "crs": "EPSG:4326"
    },
    "latLonBoundingBox": {
      "minx": '$MINX',
      "maxx": '$MAXX',
      "miny": '$MINY',
      "maxy": '$MAXY',
      "crs": "EPSG:4326"
    },
    "enabled": true,
    "store": {
      "@class": "dataStore",
      "name": "osm:osm",
      "href": "http://geoserver:8080/geoserver/rest/workspaces/osm/datastores/osm.json"
    },
  }
}'

done

LAYER_GROUP='{
  "layerGroup": {
    "name": "osm",
    "mode": "SINGLE",
    "publishables": {
      "published": [
        {
          "@type": "layer",
          "name": "osm:landuse_a",
          "href": "http://localhost:8080/geoserver/rest/workspaces/osm/layers/landuse_a.json"
        },
        {
          "@type": "layer",
          "name": "osm:roads",
          "href": "http://localhost:8080/geoserver/rest/workspaces/osm/layers/roads.json"
        },
        {
          "@type": "layer",
          "name": "osm:nature",
          "href": "http://localhost:8080/geoserver/rest/workspaces/osm/layers/nature.json"
        }
      ]
    },
    "bounds": {
      "minx": '${TOT_MINX}',
      "maxx": '${TOT_MAXX}',
      "miny": '${TOT_MINY}',
      "maxy": '${TOT_MAXY}',
      "crs": "EPSG:4326"
    }
  }
}'
curl -v -u admin:geoserver -H 'Content-type: application/json' -XPOST http://geoserver:8080/geoserver/rest/layergroups/ -d "$LAYER_GROUP"
