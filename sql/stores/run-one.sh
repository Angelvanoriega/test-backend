#!/bin/bash
psql --host 127.0.0.1 --port 5432 --username dataclean --dbname dataclean -a -w -f ${1}
echo "ok.."