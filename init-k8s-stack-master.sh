#!/usr/bin/sh

# 只在 master 节点执行
# 替换 x.x.x.x 为 master 节点实际 IP（请使用内网 IP）
# export 命令只在当前 shell 会话中有效，开启新的 shell 窗口后，如果要继续安装过程，请重新执行此处的 export 命令
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

# 设置主机域名解决
cat --number /etc/hosts
sed -i "s/${MASTER_IP} ${APISERVER_NAME}//g" /etc/hosts
sed -i '${/^$/d}' /etc/hosts
echo $OLD_HOST_CONFIG >>/etc/hosts

# 配置软件kubeadm
kubeadm config print init-defaults >kubeadm-init-k8s-${K8S_VERISON}.yaml
#cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml
#2 设置广播地址
sed -i "s/advertiseAddress: 1.2.3.4/advertiseAddress: $MASTER_IP/g" kubeadm-init-k8s-${K8S_VERISON}.yaml
#2 使用国内镜像
#cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml | grep "k8s.gcr.io"
OLD_REPS_URL="imageRepository: k8s.gcr.io"
NEW_REPS_URL="imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers"
sed -i "s#$OLD_REPS_URL#$NEW_REPS_URL#g" kubeadm-init-k8s-${K8S_VERISON}.yaml
#2 修改软件版本
#cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml | grep "kubernetesVersion:"
sed -i "s/kubernetesVersion: .*/kubernetesVersion: $K8S_VERISON/g" kubeadm-init-k8s-${K8S_VERISON}.yaml
#cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml | grep "kubernetesVersion:"
#2 修改服务网段
#cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml | grep -E '([0-9]{1,3}.?){4}/[0-9]{2}'
#cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml | grep -oE '([0-9]{1,3}.?){4}/[0-9]{2}'
#cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml | grep "serviceSubnet: .*"
sed -i "s/serviceSubnet: .*/serviceSubnet: $SERVICE_SUBNET/g" kubeadm-init-k8s-${K8S_VERISON}.yaml
#cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml | grep "serviceSubnet: .*"
#2 修改单元网段
sed -i "37a podSubnet: ${POD_SUBNET}" kubeadm-init-k8s-${K8S_VERISON}.yaml
sed -i '38s/^ *//g' kubeadm-init-k8s-${K8S_VERISON}.yaml
SPACE_LENGTH=$(printf "%2s" ' ')
sed -i "38s/^/$SPACE_LENGTH/" kubeadm-init-k8s-${K8S_VERISON}.yaml
cat --number kubeadm-init-k8s-${K8S_VERISON}.yaml

# 需何镜像（按需使用）
# kubeadm config images list --kubernetes-version=${K8S_VERSION}
# 下拉镜像（按需使用）
kubeadm config images pull --config kubeadm-init-k8s-${K8S_VERISON}.yaml
# 测试运行（按需使用）
#2 1.15.0|
# kubeadm init --config=kubeadm-init-k8s-${K8S_VERISON}.yaml --upload-certs --dry-run
#2 1.15.3|
# kubeadm init --config=kubeadm-init-k8s-${K8S_VERISON}.yaml --dry-run

# 始化软件kubeadm
#kubeadm init --config=kubeadm-init-k8s-${K8S_VERISON}.yaml --upload-certs
#2 1.15.3|
kubeadm init --config=kubeadm-init-k8s-${K8S_VERISON}.yaml

# 配置软件kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 检查软件kubectl
#2 查看所需镜像
kubeadm config images list --kubernetes-version=${K8S_VERSION}
#2查看已下镜像
docker image ls
#2查看节点状态
kubectl get node #此处的NotReady状态是因为网络还没配置。

#####
# 安装网络
#####
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

#####
# 安装面板
#####
# D:\code-store\Shell\k8s-uses-web-ui-dashboard

#####
# 安装监控
#####
# heapster(kubernetesv1.11之前)
# Metrics-Server(kubernetesv1.11之后)
# https://github.com/kubernetes-incubator/metrics-server
# Prometheus
# https://github.com/coreos/prometheus-operator

#####
# 安装日志
#####
# EFK
# https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch

#####
# 安装存储
#####
# glusterfs + heketi
# https://jimmysong.io/kubernetes-handbook/practice/using-heketi-gluster-for-persistent-storage.html

#####
# 添加节点
#####
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

####
# 可选-在非主节点上管理集群
#####
# https://www.cnblogs.com/RainingNight/archive/2018/05/02/8975838.html
:: <<manage-k8s-on-non-node
K8S_MASTER_IP=192.168.1.2
scp root@$K8S_MASTER_IP:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf get nodes
#scp root@192.168.1.2:$HOME/.kube/config .
#scp -i ~/.ssh/google-clound-ssr root@192.168.1.2:/root/.kube/config $HOME/.kube/

manage-k8s-on-non-node

#####
# 可选-从集群外部连接到API服务
#####
# https://www.cnblogs.com/RainingNight/archive/2018/05/02/8975838.html
:: <<map-proxy-from-centos7-to-win
K8S_MASTER_IP=192.168.1.2
scp root@$K8S_MASTER_IP:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf proxy
map-proxy-from-centos7-to-win

#####
# 可选-部署一个微服务
#####
# https://www.cnblogs.com/RainingNight/archive/2018/05/02/8975838.html
:: <<k8s-manage-a-micro-service
kubectl create namespace sock-shop
kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"
kubectl -n sock-shop get svc front-end
kubectl get pods -n sock-shop
#http://<master_ip>/<cluster-ip>:<port>
kubectl delete namespace sock-shop
k8s-manage-a-micro-service

#####
# 集群升级
#####
:: <<upgrade-k8s
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
upgrade-k8s

#####
# 卸载清理k8s
#####
:: <<delete-k8s


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
delete-k8s

##### 成功案例
# docker18.09.9-k8s1.15.3-calcio3.8.4-dashboad

##### 参考文献
# https://kuboard.cn/install-script/v1.16.0/init-master.sh
#sed与正则表达式
#https://www.cnblogs.com/zd520pyx1314/p/6061339.html
