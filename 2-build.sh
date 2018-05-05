#!/bin/bash

echo "--> Loading Configuration..."
source ./env.sh

# Could use virt-install ... --extra-args="ip=[ip]::[gateway]:[netmask]:[hostname]:[interface]:[autoconf]"
# eg:
# ip=192.168.88.123::192.168.88.1:255.255.255.0:test.example.com:eth0:none"

echo "--> Building VMs..."
for i in `cat hosts|grep -v \\\\[`;
do

    echo "--> Building $i..."

    NAME=$(echo $i| cut -d'.' -f 1)
    echo "---> Using Base Name: $NAME"

    baseimage="$VMS/$i-base.qcow2"
    image="$VMS/$i.qcow2"
    dockerdisk="$VMS/$i-docker.qcow2"

    echo "---> Starting Dry Run for $i w/ MAC ${MACADDRESS[$NAME]}"

    virt-install --ram $VMRAM  --vcpus 4 --os-variant rhel7 --disk path=$image,device=disk,bus=virtio,format=qcow2 \
        --noautoconsole --vnc --name $i --dry-run --cpu host-passthrough,+vmx --network bridge=${BRIDGE},mac=${MACADDRESS[$NAME]} \
    	--print-xml > $VMS/$i.xml

    echo "----> Defining VM $i..."
    virsh define --file $VMS/$i.xml
    echo "----> Attaching Disk to $i, Using $dockerdisk..."
    virsh attach-disk $i --source $dockerdisk --target vdb --persistent

    echo "----> VM $i Built]"
done

echo "--> Listing VMs..."
echo "======="
virsh list --all
echo "======="
echo "--> VM Build Complete"
