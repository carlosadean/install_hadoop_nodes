#!/bin/bash

if test -z "$1" -o -z "$2"
then
    echo "Usage $0 <hostname> <path_to_hadoop_install_archive>"
    echo "NOTE: use uhadoop user from webback2!"
    echo "      Stop hadoop first, run and then start up hadoop again"
    echo "Example: $0 nc21 /home/uhadoop/install/hadoop-2.6.0_configured.tar.gz"
    exit 1
fi

HOST="$1"
ARCHIVE_PATH="$2"
ARCHIVE=`basename $ARCHIVE_PATH`
DEST_DIR=/hadoop-install/hadoop-2.6.0

if test ! -f $ARCHIVE_PATH
then
    echo "Error: <path_to_hadoop_install_archive> must exists"
    exit 2
fi

if `ssh nc20 test ! -d $DEST_DIR`
then
   ####
   echo You must re-create the dest dir, following the example below
   echo ssh -t "$HOST" sudo bash -c "\"mkdir -p $DEST_DIR && chown uhadoop:users $DEST_DIR && chmod 2775 $DEST_DIR\""
   exit 3
fi



####
echo Copy the archive file to a temp destination
scp "$ARCHIVE_PATH" "$HOST:/tmp/"
test "$?" -ne 0 && { echo "Error 4, exit."; exit 4; }

####
echo Cleanup the dest dir
# NOTE: do not use VARS in rm -rf commands!
ssh "$HOST" bash -c "\"rm -rf /hadoop-install/hadoop-2.6.0/*\""
test "$?" -ne 0 && { echo "Error 5, exit."; exit 5; }

####
echo Uncompress the archive in the destination
ssh "$HOST" bash -c "\"cd $DEST_DIR/../ && tar -xzf /tmp/$ARCHIVE\""
test "$?" -ne 0 && { echo "Error 6, exit."; exit 6; }

####
echo Setup the correct ownership
ssh "$HOST" bash -c "\"chown -R uhadoop:users $DEST_DIR/*\""
test "$?" -ne 0 && { echo "Error 7, exit."; exit 7; }

####
echo Remove the temp archive
ssh  "$HOST" bash -c "\"rm /tmp/$ARCHIVE\""
test "$?" -ne 0 && { echo "Error 8, exit."; exit 8; }



####
# End
echo Exit succesfully.
