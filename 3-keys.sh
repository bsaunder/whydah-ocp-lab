#!/bin/bash

echo "--> Loading Configuration..."
source ./env.sh

echo "--> Starting Key Copy..."
for i in `cat hosts|grep -v \\\\[`;
do
	echo "--> Copying Key to $i..."
	ssh-copy-id root@$i
	echo "--> Copying Key to $i..."
done
echo "--> Key Copy Complete"
