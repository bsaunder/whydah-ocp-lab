#!/bin/bash

echo "--> Starting All VMs..."
for i in `cat hosts|grep -v \\\\[`;
do 
	virsh start $i
	sleep 5
done
echo "--> All VMs Started"
echo "--> Checking VM Status..."
echo "======="
virsh list
echo "======="
echo "--> Done"
