# use

```
# /install.sh master
```
or
```
# /install.sh node
```

# init master (+weave CNI)
```
# iptables -F && iptables -t nat -F && \
    iptables -t mangle -F && \
    iptables -X && \
    kubeadm init --pod-network-cidr=10.244.0.0/16 && \
    mkdir -p $HOME/.kube && \
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
    chown $(id -u):$(id -g) $HOME/.kube/config && \
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.244.0.0/16"
```

# init node
```
# iptables -F && iptables -t nat -F && \
    iptables -t mangle -F && \
    iptables -X && \
    kubeadm join 10.0.0.115:6443 --token b41e5q.ahhq5yoqer2eqhg0 \
        --discovery-token-ca-cert-hash sha256:4355a3357d4da44215c756afc5bd64db893ee6d68fb0978586b20cfbba70cad2
```

# test nginx deployment, expose & scale 
```
# kubectl create deployment nginx --image=nginx && \
    kubectl expose deployment nginx --port=80 --type=NodePort && \
    kubectl scale deployment nginx --replicas=4 && \
    kubectl get svc
```

# test dns
```
# kubectl apply -f https://k8s.io/examples/admin/dns/busybox.yaml
# kubectl exec -ti busybox -- nslookup kubernetes.default
```
