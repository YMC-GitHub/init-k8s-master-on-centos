#!/usr/bin/sh

# 设置主机域名解决
cat --number /etc/hosts
sed -i "s/${MASTER_IP} ${APISERVER_NAME}//g" /etc/hosts
sed -i '${/^$/d}' /etc/hosts
echo $OLD_HOST_CONFIG >>/etc/hosts

# 创建相关目录
mkdir -p $K8S_PATH

# 配置软件kubeadm
cd $K8S_PATH
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
#kubeadm init --config=kubeadm-init-k8s-${K8S_VERISON}.yaml
kubeadm init --config=kubeadm-init-k8s-${K8S_VERISON}.yaml | tee kubeadm-init-k8s-${K8S_VERISON}.log

# 配置软件kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 检查软件kubectl
#2 查看所需镜像
kubeadm config images list --kubernetes-version=${K8S_VERSION}
#2 查看已下镜像
docker image ls
#2 查看节点状态
kubectl get node #此处的NotReady状态是因为网络还没配置。

#####
# 安装网络
#####
# use-network.sh

#####
# 安装面板
#####
# use-web-ui-dashboard.sh

#####
# 安装监控
#####
# use-monitor.sh

#####
# 安装日志
#####
# use-log.sh

#####
# 安装存储
#####
# use-storage.sh

#####
# 添加节点
#####
# set master as worker node
kubectl taint nodes --all node-role.kubernetes.io/master-
:: <<add-workers-to-k8s
./add-workers-to-k8s.sh
add-workers-to-k8s

####
# 管理集群-在非主节点上（可选）
#####
:: <<manage-k8s-on-non-node
./manage-k8s-on-non-node.sh
manage-k8s-on-non-node

#####
# 管理集群-从集群外部连接到API服务(可选)
#####
# https://www.cnblogs.com/RainingNight/archive/2018/05/02/8975838.html
:: <<map-proxy-from-centos7-to-win
K8S_MASTER_IP=192.168.1.2
scp root@$K8S_MASTER_IP:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf proxy
map-proxy-from-centos7-to-win

#####
# 部署服务(可选)
#####
:: <<k8s-manage-a-micro-service
./deploy-service-to-k8s.sh
k8s-manage-a-micro-service

#####
# 升级集群
#####
:: <<upgrade-k8s
./upgrade-k8s.sh
upgrade-k8s

#####
# 卸载集群
#####
:: <<delete-k8s
./delete-k8s.sh
delete-k8s

##### 成功案例
# docker18.09.9-k8s1.15.3-calcio3.8.4-dashboad

##### 参考文献
# https://kuboard.cn/install-script/v1.16.0/init-master.sh
#sed与正则表达式
#https://www.cnblogs.com/zd520pyx1314/p/6061339.html
