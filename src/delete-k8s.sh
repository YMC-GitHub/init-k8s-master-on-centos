#!/bin/sh

kubeadm reset --force
rm -rf /root/.kube/
rm -rf /etc/kubernetes/
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /etc/systemd/system/kubelet.service
rm -rf /usr/bin/kube*
rm -rf /etc/cni

rm -rf /opt/cni
rm -rf /var/lib/etcd
rm -rf /var/etcd

##########
# reference
##########
# https://blog.csdn.net/ccagy/article/details/85845979
