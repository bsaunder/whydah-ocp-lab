# See README.md
export OCP_LIST="master0 node0 node1 node2"
export JUMP_LIST="jump"
export DOMAIN="nip.io"
declare -A IPADDRESS=( \
    ["jump"]="192.168.1.59" \
    ["master0"]="192.168.1.107" \
    ["master1"]="192.168.1.145" \
    ["master2"]="192.168.1.16" \
    ["lb"]="192.168.1.175" \
    ["node0"]="192.168.1.245" \
    ["node1"]="192.168.1.246" \
    ["node2"]="192.168.1.248" \
)
declare -A MACADDRESS=( \
    ["jump"]="52:54:00:42:B4:AD" \
    ["master0"]="52:54:00:2C:C2:A0" \
    ["master1"]="52:54:00:AC:C6:E1" \
    ["master2"]="52:54:00:DE:6B:C4" \
    ["lb"]="52:54:00:96:FF:84"   \
    ["node0"]="52:54:00:4A:22:9B"   \
    ["node1"]="52:54:00:4A:22:9C"   \
    ["node2"]="52:54:00:4A:22:9D"   \
)
export OCPDOMAIN="btsaunde.com"
export WORKSPACE="$HOME/ocp"
export VMS="$WORKSPACE/VMs"
export ISOS="$HOME/ISOs"
export RHEL_IMAGE="$ISOS/rhel-guest-image-7.3-35.x86_64.qcow2"
export BRIDGE="br0" # or virbr0 depending on your needs
export VMRAM=16384
export VMROOTDISK=120G
export VMDOCKERDISK=10G
