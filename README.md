# Whydah Home OCP Lab
Scripts used to quickly build and teardown an OCP Lab on my Home Server (Whydah).


## What do you get

* 8 RHEL7.3 VMs running in KVM
* Registered and appropriate subscriptions attached
* required RPMs installed, including atomic-openshift-installer
* docker installed and storage configured
* ready to install the OpenShift cluster from the jump VM.

## Requirements

* Access to DNS server.  I'm using a personal domain hosted on
  domains.google.com.
* Access to DHCP server. I'm using my home router and tie
  specific IP addresses to known mac addresses. ie: VMs always get the
  same IP address from DHCP.
* RHEL 7 KVM hypervisor
* `rhel-guest-image-7.3-35.x86_64.qcow2` (from https://access.redhat.com/downloads/)
* 2 NICs on your hypervisor.  I use an onboard NIC plus an inexpensive USB NIC.

## Setup

### Install Ansible

Enable Ansible Repos

	`sudo subscription-manager repos --enable rhel-7-server-ansible-2.5-rpms`

Install Ansible

	`sudo yum -y install ansible`

### Install Virtualization Tools

Install libguestfs

	`sudo yum -y install libguestfs-tools`

### Edit Environment File

Edit `env.sh` for your environment:
  - VM_LIST - the names of the VMs to create
  - DOMAIN - the domain name to use for the hosts (ie: batcluster)
  - MACADDRESS - MAC addresses for your VMs (be unique)
  - OCPDOMAIN - the domain name for the cluster (ie: ocp.btsaunde.com,
    *.apps.btsaunde.com)
  - WORKSPACE, VMS - where VMs, etc are stored
  - ISOS - where your ISOs can be found
  - RHEL_IMAGE - your rhel-guest-image-7.3-35.x86_64.qcow2 is
  - BRIDGE - which bridge to use.  See Network Notes below

### Update DNS

I am using nip.io for my DNS to point to the local addresses so it looks like this. eg:

        $ nslookup jump.$IPADDRESS.$DOMAIN
        Server:		8.8.8.8
        Address:	8.8.8.8#53

        Non-authoritative answer:
        Name:	jump.$IPADDRESS.$DOMAIN
        Address: 192.168.1.107

You need to setup wildcard DNS entries for `*.ocp.$OCPDOMAIN` and `*.apps.$OCPDOMAIN` to point to `lb.$IPADDRESS.$DOMAIN` in your DNS server. I am using Google Domains for this.

### Update DHCP Server

Tie these specific IP addresses defined in DNS to known mac
addresses. ie: VMs always get the same IP address from DHCP.

#### DNS -> MAC Address Mappings

|Host |MAC Address | Assigned IP |
|--- | --- | --- |
|jump.$DOMAIN|52:54:00:42:B4:AD|192.168.1.59|
|master0.$DOMAIN|52:54:00:2C:C2:A0|192.168.1.107|
|master1.$DOMAIN|52:54:00:AC:C6:E1|192.168.1.145|
|master2.$DOMAIN|52:54:00:DE:6B:C4|192.168.1.16|
|lb.$DOMAIN|52:54:00:96:FF:84|192.168.1.175|
|node1.$DOMAIN|52:54:00:4A:22:9B|192.168.1.245|
|node2.$DOMAIN|52:54:00:4A:22:9C|192.168.1.246|
|node3.$DOMAIN|52:54:00:4A:22:9D|192.168.1.248|

### Network Bridge Setup

  I added a second NIC in the form of an inexpensive USB 3 NIC
  (enp35s0f3u2).

  Here are the NetworkManager CLI commands to create another bridge
  (br0) and have enp35s0f3u2 bound (aka slaved) to it.

  `nmcli con add type bridge ifname br0`

  `nmcli con show` # some will be yellow

  `nmcli -f bridge con show bridge-br0` # just take a look

  `nmcli con add type bridge-slave ifname enp35s0f3u2 master br0`

  `ifup br0`

  `nmcli con show`  # all green

  Then edit /etc/qemu-kvm/bridge.conf to add:

  `allow br0`

  Optional just finishing up libvirt config

  `virsh net-list --all`

  If you don't see a `default` network entry from the previous
  command, do this:

  `virsh net-define /usr/share/libvirt/networks/default.xml`

  `virsh net-start default`

  `virsh net-autostart default`

### Edit `variables.yml`

 You need to set the `openshift_subscription_pool` for your own Red Hat account.
  Use this command will find your pool id:

  `subscription-manager list --all --available --matches "*openshift*"`

  You also need to set your RHN Username and Password

  Make `variable.yml` look something like this:

  `openshift_subscription_pool: 8a85f98660c23a380160c2fa54a2300c`

### Create `vault.yml`

  Create a vault to store your own Red Hat subscription
  username/password in variables. (ie: what you use on the Red Hat
  portal)

  `ansible-vault create vault.yml`

  Set your RHN credentials using the following format

  `vault_rhn_username: my-rhn-support-username`
  `vault_rhn_password: secretpassword-for-rhn`

  Take a look at the resulting file and it should not have the
  variables in cleartext.

## VM Creation

*   `0-generate.sh` -- Create hosts and hosts.ocp based on your env.sh settings
*   `1-create.sh` -- Create qemu files for OS, container storage, OS config
*   `2-build.sh` -- Install VMs and attach disks
*   `start-all.sh` -- boot them up
*   `3-keys.sh` -- push ssh keys around
*   `4-prep.sh` -- update the VMs with required packages, etc
*   `5-cluster.sh` -- copy files to jump VMs and remind the next steps

## Post configuration

### Install OpenShift

* `hypervisor# ssh root@jump.gwiki.com # password is redhat`
* `jump#       ssh-keygen`
* `jump#       bash ./3-keys.sh`
* `jump#       ansible-playbook -i hosts.ocp /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml`

* Once the cluster is created, ssh root@master0 and create a non-admin user:

  `# touch /etc/origin/master/htpasswd`

  `# htpasswd /etc/origin/master/htpasswd someuser`

### Start using OpenShift

The easiest way to get started is to point a browser to
https://ocp.$OCPDOMAIN:8443/ (in my example,
https://ocp.nozell.com:8443)


## TODO

* Fix warning messages from ansible (replace sudo with become/become_user/become_method, service module, etc)

## Credits
Based on the original work from [Marc Nozell](mailto:mnozell@redhat.com) (irc: [MarcNo](mailto:marc@nozell.com))
