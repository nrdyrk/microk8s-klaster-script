
#!/bin/sh

# microk8s config and install for raspberry pi
echo "microK8s setup script"

set -e  # exit immediately on error
set -u  # fail on undeclared variables

CHANNEL=${CHANNEL:-1.21/stable}

# Must be root user
if [ "$(id -u)" != "0" ] ; then
	echo "Sorry, you are not root."
	exit 2
fi

# Hostname input
if [ ! -n "$1" ] ; then
	echo 'Missing argument: new_hostname'
	exit 1
fi

CUR_HOSTNAME=$(cat /etc/hostname)
NEW_HOSTNAME=$1

# Display the current hostname
echo "The current hostname is $CUR_HOSTNAME"

# Change the hostname
hostnamectl set-hostname $NEW_HOSTNAME
hostname $NEW_HOSTNAME

# Change hostname in /etc/hosts & /etc/hostname
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname

# Display new hostname
echo "The new hostname is $NEW_HOSTNAME"

# Turn off swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Update everything
sudo apt update

# Enable cgroup memory
sudo sed -e '1s/$/ cgroup_memory=1 cgroup_enable=memory/' -i /boot/firmware/cmdline.txt

# install kubernetes .. using current known working version
snap install microk8s --classic --channel=${CHANNEL}
# use the kubectl that matches the microk8s kubernetes version
snap alias microk8s.kubectl kubectl
# export the kubectl config file in case other tools rely on this
mkdir -p $HOME/.kube
microk8s.kubectl config view --raw > $HOME/.kube/config
echo "Waiting for kubernetes core services to be ready.."
microk8s.status --wait-ready
# enable common services
# microk8s.enable dns dashboard storage
# This gets around an open issue with all-in-one installs
iptables -P FORWARD ACCEPT

# until [[ `kubectl get pods -n=kube-system | grep -o 'ContainerCreating' | wc -l` == 0 ]] ; do
#   echo "Waiting for kubernetes addon service pods to be ready..  ("`kubectl get pods -n=kube-system | grep -o 'ContainerCreating' | wc -l`" not running)"
#   sleep 5
# done

echo "Done!"