#!/bin/sh

#####
# 可选-部署一个微服务
#####
kubectl create namespace sock-shop
kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"
kubectl -n sock-shop get svc front-end
kubectl get pods -n sock-shop
#http://<master_ip>/<cluster-ip>:<port>
#kubectl delete namespace sock-shop

#####
# reference
#####
# https://www.cnblogs.com/RainingNight/archive/2018/05/02/8975838.html
