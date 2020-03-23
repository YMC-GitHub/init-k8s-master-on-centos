#!/bin/sh
##########
# 升级集群版本
##########
K8S_VERSION=1.13.2
#查看可用的更新版本
kubeadm upgrade plan
#下载要升级到的版本
yum install kubeadm-${K8S_VERSION} kubelet-${K8S_VERSION} kubectl-${K8S_VERSION}
#将它升到指定的版本
kubeadm upgrade apply v${K8S_VERSION}
#对它进行重新启动
systemctl restart kubelet
#看升级后的节点版本
kubectl get nodes

##########
# 升级pod
##########
