#!/bin/bash

if [ -z "$PLUGIN_HOSTS" ]; then
    echo "Specify at least one host!"
    exit 1
fi

if [ -z "$PLUGIN_TARGET" ]; then
    echo "Specify a target!"
    exit 1
fi

PORT=$PLUGIN_PORT
if [ -z "$PLUGIN_PORT" ]; then
    echo "Port not specified, using default port 22!"
    PORT=22
fi

SOURCE=$PLUGIN_SOURCE
if [ -z "$PLUGIN_SOURCE" ]; then
    echo "No source folder specified, using default './'"
    SOURCE="./"
fi

USER=$RSYNC_USER
if [ -z "$RSYNC_USER" ]; then
    if [ -z "$PLUGIN_USER" ]; then
        echo "No user specified, using root!"
        USER="root"
    else
        USER=$PLUGIN_USER
    fi
fi

PASSWORD_FILE=$PLUGIN_PASSWORD_FILE

if [ -z "$PLUGIN_PASSWORD_FILE" ]; then
   echo "At least specified password_file"
fi

if [ -z "$PLUGIN_ARGS" ]; then
    ARGS=
else
    ARGS=$PLUGIN_ARGS
fi

# Building rsync command
expr="rsync -azP $ARGS"

if [[ -n "$PLUGIN_RECURSIVE" && "$PLUGIN_RECURSIVE" == "true" ]]; then
    expr="$expr -r"
fi

if [[ -n "$PLUGIN_DELETE" && "$PLUGIN_DELETE" == "true" ]]; then
    expr="$expr --del"
fi

if [ -n "$PLUGIN_PASSWORD_FILE" ]; then
    expr="$expr --password-file=$PASSWORD_FILE"
fi

# Include
IFS=','; read -ra INCLUDE <<< "$PLUGIN_INCLUDE"
for include in "${INCLUDE[@]}"; do
    expr="$expr --include=$include"
done

# Exclude
IFS=','; read -ra EXCLUDE <<< "$PLUGIN_EXCLUDE"
for exclude in "${EXCLUDE[@]}"; do
    expr="$expr --exclude=$exclude"
done

# Filter
IFS=','; read -ra FILTER <<< "$PLUGIN_FILTER"
for filter in "${FILTER[@]}"; do
    expr="$expr --filter=$filter"
done

expr="$expr $SOURCE"

chmod 0600 $PASSWORD_FILE

# Run rsync
IFS=','; read -ra HOSTS <<< "$PLUGIN_HOSTS"
result=0
for host in "${HOSTS[@]}"; do
    echo $(printf "%s" "$ $expr $USER@$host::$PLUGIN_TARGET")
    $expr $USER@$host:$PLUGIN_TARGET
    result=$(($result+$?))
    if [ "$result" -gt "0" ]; then exit $result; fi
done

exit $result
