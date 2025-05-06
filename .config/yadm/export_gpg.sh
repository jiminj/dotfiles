#!/bin/bash

umask 0077 # -rwx------
EXPORT_PATH="$HOME/.gnupg/.exported-keyring"
if [ -d "$EXPORT_PATH" ]; then
  chmod "$EXPORT_PATH"
else
  mkdir -p "$EXPORT_PATH"
fi

if [ ! -d "$EXPORT_PATH" ]; then
  echo "Unable to create dir $EXPORT_PATH"
  echo "Aborting"
  exit 1
fi

echo "Exporting private key to $EXPORT_PATH"
gpg -a --export-secret-key -o "$EXPORT_PATH/private-key.asc"
echo "Exporting public keyring to $EXPORT_PATH"
gpg -a --export -o "$EXPORT_PATH/public-key.asc"
echo "Exporting ownertrust to $EXPORT_PATH"
gpg --export-ownertrust > "$EXPORT_PATH/ownertrust.txt"

