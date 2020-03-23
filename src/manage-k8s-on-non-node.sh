#!/bin/sh

####
# 管理集群-在非主节点上（可选）
#####
K8S_MASTER_IP=192.168.1.2
scp root@$K8S_MASTER_IP:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf get nodes
#scp root@192.168.1.2:$HOME/.kube/config .
#scp -i ~/.ssh/google-clound-ssr root@192.168.1.2:/root/.kube/config $HOME/.kube/

#####
# reference
#####
# https://www.cnblogs.com/RainingNight/archive/2018/05/02/8975838.html
