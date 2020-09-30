#!/bin/bash

if [ "$1" == "master" ]; then
  echo "master"
elif [ "$1" == "node" ]; then
  echo "node"
else
  echo "usage : /kubernetes-install.sh <node-type>"
  exit
fi

if [ "$1" == "master" ]; then
  firewall-cmd --permanent --add-port=6443/tcp
  firewall-cmd --permanent --add-port=2379-2380/tcp
  firewall-cmd --permanent --add-port=10250/tcp
  firewall-cmd --permanent --add-port=10251/tcp
  firewall-cmd --permanent --add-port=10252/tcp
  firewall-cmd --reload
elif [ "$1" == "node" ]; then
  firewall-cmd --permanent --add-port=10250/tcp
  firewall-cmd --permanent --add-port=30000-32767/tcp
  firewall-cmd --reload
fi

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
lsmod | grep br_netfilter
modprobe br_netfilter

cat << EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

if [ "$1" == "master" ]; then
  echo "source <(kubectl completion bash)" >> ~/.bashrc
fi

echo "install complete"
