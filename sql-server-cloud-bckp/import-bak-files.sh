#!/bin/bash

BLOB_STORAGE_URL=$BLOB_STORAGE_URL
DEST_DIR=$DEST_DIR
AZCOPY_CMD=$AZCOPY_CMD

echo "Downloading backups from Blob Storage"

$AZCOPY_CMD cp "$BLOB_STORAGE_URL" $DEST_DIR --recursive=true

if [ $? -eq 0 ]; then
  echo "Backups downloaded succesfully!"
else
  echo "Error when downloading."
  exit 1
fi