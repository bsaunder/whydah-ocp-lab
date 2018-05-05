#!/bin/bash

echo "--> Loading Configuration..."
source ./env.sh

echo "--> Starting VM Creation..."
if [ ! -d $VMS ]
then
    echo "--> Creating $VMS Directory"
    mkdir -p $VMS
fi

for i in `cat hosts|grep -v \\\\[`;
do

    echo "--> Starting VM $i"

    baseimage="$VMS/$i-base.qcow2"
    image="$VMS/$i.qcow2"
    dockerdisk="$VMS/$i-docker.qcow2"

    echo "----> Creating a $VMROOTDISK disk for root, Using $image"
    qemu-img create -f qcow2 $baseimage $VMROOTDISK
    virt-resize --expand /dev/sda1 $RHEL_IMAGE $baseimage

    qemu-img create -f qcow2 -b $baseimage $image

    echo "----> Creating a $VMDOCKERDISK disk for docker, Using $dockerdisk]"
    qemu-img create -f raw $dockerdisk $VMDOCKERDISK

    echo "----> Customizing $i VM"
    virt-customize -a $image --run-command 'yum remove cloud-init* -y'
    virt-customize -a $image --root-password password:redhat
    virt-customize -a $image --hostname "$i"
    echo "----> $i Created]"

done

echo "--> Create Complete"
exit
