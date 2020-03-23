#!/bin/sh

# 替换 x.x.x.x 为 master 节点实际 IP（请使用内网 IP）
export MASTER_IP=192.168.2.3
# 替换 apiserver.demo 为 您想要的 dnsName (不建议使用 master 的 hostname 作为 APISERVER_NAME)
export APISERVER_NAME=apiserver.demo
# Kubernetes 容器组所在的网段，该网段安装完成后，由 kubernetes 创建，事先并不存在于您的物理网络中
export POD_SUBNET=10.100.0.1/20
export SERVICE_SUBNET=10.96.0.0/16 #10.96.0.0/12
#软件版本
#K8S_VERISON="1.16.0"
K8S_VERISON="1.15.3"
#K8S_VERISON="1.14.3"
#K8S_VERISON="1.10.1"

# 工作目录
K8S_PATH=/root/k8s
