#!/bin/bash
#########################################
# Define source and destinations

MONGO_DBS=""
BACKUP_TMP=~/tmp
BACKUP_DEST=~/backups
MONGODUMP_BIN=/Users/wahyusumartha/Documents/mongodb-db/bin/mongodump
TAR_BIN=/usr/bin/tar
HOST=xxx
USERNAME=xxx
PASSWORD=xxx
DATABASE=xxx

#######################################

BACKUPFILE_DATE=`date +%Y%m%d-%H%M`

# _do_store_archive <Database> <Dump_Dir> <Dest_Dir> <Dest_File>

function _do_store_archive {
	mkdir -p $3
	cd $2
	tar -cvzf $3/$4 dump
}

# _do_backup <Database name>

function _do_backup {
	UNIQ_DIR="$BACKUP_TMP/$1"`date "+%s"`
	mkdir -p $UNIQ_DIR/dump
	echo "dumping Mongo Database $1"
	if [ "all" = "$1" ]; 
	then
		$MONGODUMP_BIN -h $HOST -u $USERNAME -p $PASSWORD -o $UNIQ_DIR/dump		
	else
		$MONGODUMP_BIN -h $HOST -u $USERNAME -p $PASSWORD -d $1 -o $UNIQ_DIR/dump
	fi
	KEY="database-$BACKUPFILE_DATE.tgz"
	echo "Archiving Mongo Database to $BACKUP_DEST/$1/$KEY"
	DEST_DIR=$BACKUP_DEST/$1

	_do_store_archive $1 $UNIQ_DIR $DEST_DIR $KEY
	
	rm -rf $UNIQ_DIR
	
}

# check to see if individual databases have been specified, otherwise backup the whole server 
# to all 

if ["" = "$MONGO_DBS"]; 
then 
	MONGO_DB=$DATABASE
	_do_backup $MONGO_DB
else 
	for MONGO_DB in $MONGO_DBS; do 
		_do_backup $MONGO_DB
	done
fi
