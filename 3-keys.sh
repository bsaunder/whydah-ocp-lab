#!/bin/bash

echo "--> Loading Configuration..."
source ./env.sh

echo "--> Removing Existing Known Hosts..."
rm ~/.ssh/known_hosts

echo "--> Starting Key Copy..."
for i in `cat hosts|grep -v \\\\[`;
do
	echo "--> Copying Key to $i..."
	ssh-copy-id root@$i
	echo "--> Key Copied to $i..."
done
echo "--> Key Copy Complete"
