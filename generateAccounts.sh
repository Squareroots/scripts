#!/bin/bash

if [ $# -lt 3 ]; then
    echo "$0 <Accountamount> <gid> <csv-output>"
    exit 1
fi

amount=$1
gid=$2
outputfile=$3

#Check, if given group exists
grep ":$gid:" /etc/group > /dev/null

if [ $? -ne 0 ]; then
   echo "gid doesn't exist"
   exit 1
fi

#print CSV Headline
echo "Username:Password" > $outputfile

for i in `seq $amount`; do
    #replace similar looking characters like I and l with other more distinctive ones
    pw="$(dd if=/dev/urandom count=1 ibs=6 2>/dev/null | base64 | tr '+/0OolI1' 'gv8H4Gwz' )"
    username="workshop$i"

    #if there is already an existing account with this name, delete it (including the home directory)
    deluser --remove-home "$username" &> /dev/null

    echo -en "\rcreating user $username ($i/$amount)"

    #Add the user and write a csv-entry, if successful
    adduser --disabled-password --gid $gid --quiet --gecos "" $username

    #Set appropriate permissions so players can't steal from other players
    chmod -R 700 /home/$username

    if [ $? -eq 0 ]; then
        echo "$username:$pw" | tee -a $outputfile | chpasswd
    fi
done

echo ""
