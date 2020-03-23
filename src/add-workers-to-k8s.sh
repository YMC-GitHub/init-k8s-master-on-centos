#!/bin/sh

# set master as worker node
kubectl taint nodes --all node-role.kubernetes.io/master-

# join any number of the control-plane node running
:: <<eof-join-any-number-of-control-plane-node
kubeadm join apiserver.demo:6443 --token 2wie33.yccuo3yoaezjeidh \
    --discovery-token-ca-cert-hash sha256:e987aab61960b3d03f4c19599b4847de2814be637d4987fbe1251cdebf8dbb50 \
    --control-plane --certificate-key 66a90ad7fc8321768a6a4d89766f35b3e7e87a6c683e7fd389781a3b43bac5e5
eof-join-any-number-of-control-plane-node

# join any number of worker nodes
#2 1.15.3|
:: <<eof-join-any-number-of-control-worker-nodes
kubeadm join 192.168.1.2:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:de0fd619909ccee2eeb5dc47a9d621ffe8c846769e5d2603deee9892680e80c0
eof-join-any-number-of-control-worker-nodes
