#!/bin/sh

# K8S集群默认不会将Pod调度到Master上，这样Master的资源就浪费了。
# 可以不使用minikube而创建一个单节点的K8S集群.

# set master as worker node
kubectl taint nodes --all node-role.kubernetes.io/master-
