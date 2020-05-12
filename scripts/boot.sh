#!/bin/bash
#add the user
adduser --quiet --home /OUTPUT --no-create-home --gecos "" --shell /bin/bash --disabled-password mesap

#update the IDs to those passed into docker via environment variable
sed -i -e "s/1000:1000/$MYUID:$MYGID/g" /etc/passwd
sed -i -e "s/mesap:x:1000/mesap:x:$MYGID/" /etc/group

# update directory permissions with the new ones
chown -R --quiet mesap: /INPUT /OUTPUT /mesap

# su - as the user
su - mesap

