#!/bin/bash

replace_tokens() {
  eval "echo \"$(cat $1)\""
}

echo "--> Loading Configuration..."
source ./env.sh

echo "--> Removing Existing Hosts File..."
rm -v hosts

echo "--> Generating Hosts File..."

echo "[jump]">> hosts
for i in $JUMP_LIST
do
    echo $i.${IPADDRESS[$i]}.$DOMAIN >> hosts
done

echo "[ocp]">> hosts
for i in $OCP_LIST
do
    echo $i.${IPADDRESS[$i]}.$DOMAIN >> hosts
done

echo "--> Generating OCP Hosts File..."
replace_tokens ./hosts.ocp.template > ./hosts.ocp.template

echo "--> Previewing Hosts List..."
echo "======="
cat hosts
echo "======="
echo "--> Generate Complete"
