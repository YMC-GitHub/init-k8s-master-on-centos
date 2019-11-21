#!/bin/sh

cat >>/etc/hosts <<etc-hosts-conf
192.168.1.2   k8s-master
192.168.1.4   k8s-worker1
etc-hosts-conf
