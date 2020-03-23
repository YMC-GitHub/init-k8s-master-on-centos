#!/bin/sh

# 如果不创建网络，查看pod状态时，可以看到kube-dns组件是阻塞状态，集群时不可用的
# 查看节点
# kubectl get pods --namespace kube-system | grep "dns"
# 监控节点
# watch kubectl get pods --namespace kube-system
# 使用网络插件-calico
# D:\code-store\Shell\k8s-uses-calico-network
# 使用网络插件-flannel
# http://www.luyixian.cn/news_show_11429.aspx
# 参考文献
# https://kubernetes.io/docs/concepts/cluster-administration/addons/
