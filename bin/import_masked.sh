#!/bin/bash -ex
DIR=$(dirname $(dirname "$0"))
dropdb --if-exists -iU $2 $1 
createdb -U $2 -O $2 $1 
psql -q $1 $2 <<EOF
\i $DIR/sql/pre_data.sql
\i $DIR/sql/masked_data.sql
\i $DIR/sql/post_data.sql
EOF
