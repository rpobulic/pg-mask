#!/bin/bash -ex
DIR=$(dirname $(dirname "$0"))
pg_dump -U $2 -f pre_data.sql --section=pre-data $1
psql -Aqt -f ${DIR}/sql/generate_masks.sql $1 $2
pg_dump -U $2 -f post_data.sql --section=post-data $1
