#!/bin/bash

# detect if running in docker or not (eg singularity)
runenv=`grep docker /proc/1/cgroup | wc -l`

if [ "$runenv" -eq "0" ]
then
    # Running inside singularity or somewhere else as non-root, we need home as /OUTPUT
    declare -x HOME="/OUTPUT"
    cd /OUTPUT
else
    # Running inside docker as root

    #add the mesap user
    adduser --quiet --home /OUTPUT --no-create-home --gecos "" --shell /bin/bash --disabled-password mesap

    # update the UID/GID to those passed into docker via environment variable
    if [ -z "$MYUID" ]
    then
        echo "Warning: no MYUID MYGID variables set: permissions may not work for /OUTPUT directory"
    else
        # update to supplied user
        sed -i -e "s/1000:1000/$MYUID:$MYGID/g" /etc/passwd
        sed -i -e "s/mesap:x:1000/mesap:x:$MYGID/" /etc/group
    fi
    
    # update directory permissions with the new ones
    chown -R --quiet mesap: /INPUT /OUTPUT /mesap

    # su - as the user
    su - mesap
fi