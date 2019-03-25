#!/bin/bash
files_sql=`find . -type f -name '*.sql'`

arreglo=$(echo ${files_sql} | tr " " "\n")
directoryx=`pwd`
export PGPASSWORD="PGPASSWORD"
for tabla in ${arreglo}
do
    tabla=`echo -n ${tabla} | tail -c +2`
    store="${directoryx}${tabla}"
    psql --host rds.amazonaws.com --port 5432 --username dataclean --dbname dataclean -a -w -f ${store}
done
