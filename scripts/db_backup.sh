#!/bin/bash

# crontab -e
# 0 */12 * * * /home/mastodon/db_backup/backup.sh

DIR=$(dirname "${BASH_SOURCE[0]}")
DB_NAME=mastodon_production
DUMP_PATH="$DIR/$DB_NAME_$(date +"%Y-%m-%d@%H-%M").dump"

pg_dump --encoding utf8 --format c --compress 9 --file $DUMP_PATH $DB_NAME

DUMP_KEY=$DUMP_PATH | cut -c 3- # Remove the ./ from the path

s3cmd put --add-header='x-amz-tagging:autoclean=true' $DUMP_PATH s3://thegem-city-backups/$DB_NAME/$DUMP_KEY

rm $DUMP_PATH
