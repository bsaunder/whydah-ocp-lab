#!/bin/bash

source ./env.sh

# Could use virt-install ... --extra-args="ip=[ip]::[gateway]:[netmask]:[hostname]:[interface]:[autoconf]"
# eg:
# ip=192.168.88.123::192.168.88.1:255.255.255.0:test.example.com:eth0:none"

for i in `cat hosts|grep -v \\\\[`;
do

    echo "########################################################################"
    echo "[$i start]"

    NAME=$(echo $i| cut -d'.' -f 1)
    echo "Name: $NAME"

    baseimage="$VMS/$i-base.qcow2"
    image="$VMS/$i.qcow2"
    dockerdisk="$VMS/$i-docker.qcow2"

    echo "[dry-run install $i w/ mac ${MACADDRESS[$NAME]}"

    virt-install --ram $VMRAM  --vcpus 4 --os-variant rhel7 --disk path=$image,device=disk,bus=virtio,format=qcow2 \
        --noautoconsole --vnc --name $i --dry-run --cpu host-passthrough,+vmx --network bridge=${BRIDGE},mac=${MACADDRESS[$NAME]} \
    	--print-xml > $VMS/$i.xml

    echo "[define $i]"
    virsh define --file $VMS/$i.xml
    echo "[attach disk to $i, $dockerdisk]"
    virsh attach-disk $i --source $dockerdisk --target vdb --persistent

    echo "[$i done]"

done

exit


echo "########################################################################"

virsh list --all
