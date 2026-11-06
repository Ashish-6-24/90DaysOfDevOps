# Day 53 - Kubernetes Services

## Lab Objective

- Deploy an Nginx application with three replicas.
- Expose the Pods through three Kubernetes Service types:
  - `ClusterIP` for internal cluster traffic.
  - `NodePort` for access through a Kubernetes node address and port.
  - `LoadBalancer` for external access when a cloud load-balancer integration is available.
- Verify Service selectors, backend endpoints, DNS discovery, and HTTP connectivity.
- Record the observed output and any environment-specific limitations.

---

## 1. How Kubernetes Services Fit the Workload

- A **Pod** is an ephemeral workload instance and can receive a different IP address when it is replaced.
- A **Deployment** declares the desired number of application replicas and manages them through a ReplicaSet.
- A **Service** provides a stable virtual IP and DNS name for a set of selected Pods.
- The Service's `selector` matches Pod labels. The matching, ready Pods become backend endpoints.
- A Service gives clients a stable destination; it does not make individual Pod IP addresses permanent.

```text
Client / another Pod
        |
        v
Service: web-app-clusterip
        |
        +--------> Nginx Pod 1 :80
        +--------> Nginx Pod 2 :80
        +--------> Nginx Pod 3 :80
```

### Important networking fields

| Field | Meaning |
|---|---|
| `selector` | Pod labels that the Service selects. |
| `port` | Port exposed by the Service. |
| `targetPort` | Port on the selected Pod that receives traffic. |
| `nodePort` | Port opened on each node for a NodePort Service. |
| `ClusterIP` | Stable virtual IP allocated to the Service. |

- `containerPort: 80` in a Pod template documents the container's intended listening port; it does not by itself expose the application outside the Pod.
- `port` and `targetPort` can be different. For example, a Service can listen on `8080` and forward to a container port `3000`.

---

## 2. Prepare the Lab

Check that `kubectl` is connected to the intended learning cluster before applying manifests:

```bash
kubectl config current-context
kubectl get nodes -o wide
```

- Confirm the context is the intended cluster.
- Confirm the node status is `Ready`.
- If the cluster is not ready, resolve that first; do not continue by repeatedly applying manifests.

---

## 3. Task 1 - Deploy the Application

### Goal

- Create one Deployment named `web-app`.
- Request three Nginx replicas.
- Apply the same label, `app: web-app`, to each Pod so Services can select them later.

### File: `app-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

### Apply and verify

```bash
kubectl apply -f app-deployment.yaml

# Check the Deployment's desired and available replicas.
kubectl get deployment web-app

# Wait for the rollout to finish.
kubectl rollout status deployment/web-app

# Inspect the ReplicaSet created by the Deployment.
kubectl get replicasets -l app=web-app

# Show Pod status, node placement, and Pod IP addresses.
kubectl get pods -l app=web-app -o wide
```

### What to verify

- Deployment `web-app` exists.
- `READY` is `3/3` and `AVAILABLE` is `3`.
- Three Pods are `Running` and each reports `1/1` Ready.
- Each Pod has its own IP address.
- The Pod labels include `app=web-app`.

### Useful inspection commands

```bash
kubectl describe deployment web-app
kubectl get pods -l app=web-app --show-labels
```

**Why this matters:** The Deployment maintains the desired replica count. The Pod label is the connection point between this workload and the Services created in the next tasks.

---

## 4. Task 2 - Create a ClusterIP Service

### Goal

- Provide an internal, stable endpoint for the Nginx Pods.
- Select Pods labelled `app=web-app`.
- Listen on Service port `80` and forward to Pod port `80`.

### File: `clusterip-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
```

### Apply and inspect

```bash
kubectl apply -f clusterip-service.yaml

# Display the Service and its ClusterIP.
kubectl get service web-app-clusterip -o wide

# Inspect selector, ports, and backend addresses.
kubectl describe service web-app-clusterip
```

### Verify the backend endpoints

```bash
# Legacy Endpoints view; useful for a quick lab check.
kubectl get endpoints web-app-clusterip

# EndpointSlice view; the current scalable API representation.
kubectl get endpointslices \
  -l kubernetes.io/service-name=web-app-clusterip
```

- Expect the Service selector to be `app=web-app`.
- Expect the ready Nginx Pod IPs to appear as backend addresses, normally on port `80`.
- If the endpoints are empty, check Pod readiness and compare Pod labels with the Service selector.

### Test HTTP from inside the cluster

Start a temporary client Pod:

```bash
kubectl run test-client \
  --image=busybox:1.36 \
  --restart=Never \
  -it \
  --rm \
  -- sh
```

At the BusyBox prompt, run:

```sh
wget -T 5 -qO- http://web-app-clusterip
```

- A successful request should print the Nginx welcome-page HTML.
- Run the request more than once if desired.
- Identical Nginx responses do **not** identify which particular Pod served a request; use EndpointSlices to inspect the selected backends.
- Type `exit` to leave the shell. The `--rm` option removes the temporary `test-client` Pod when the session exits.

## 5. Task 3 - Discover the Service Through Kubernetes DNS

### Goal

- Use the Kubernetes DNS service-discovery mechanism instead of hard-coding a Service IP.
- Test both the short Service name and its fully qualified DNS name (FQDN).

### DNS name format

```text
<service-name>.<namespace>.svc.cluster.local
```

For this lab, in the `default` namespace:

```text
web-app-clusterip.default.svc.cluster.local
```

- Within the same namespace, the short name `web-app-clusterip` is normally sufficient.
- The FQDN explicitly identifies the Service namespace and cluster DNS suffix.
- The usual cluster DNS suffix is `cluster.local`, but a cluster can be configured with a different suffix.

### Start a dedicated DNS test Pod

```bash
kubectl run dns-test \
  --image=busybox:1.36 \
  --restart=Never \
  -it \
  --rm \
  -- sh
```

Inside the Pod:

```sh
# Inspect the DNS resolver configuration injected into this Pod.
cat /etc/resolv.conf

# Resolve the built-in Kubernetes Service.
nslookup kubernetes.default.svc.cluster.local

# Resolve this lab's Service by its short name.
nslookup web-app-clusterip

# Resolve this lab's Service by its FQDN.
nslookup web-app-clusterip.default.svc.cluster.local

# Test HTTP using the Service DNS name.
wget -T 5 -qO- http://web-app-clusterip

# Test HTTP using the FQDN.
wget -T 5 -qO- \
  http://web-app-clusterip.default.svc.cluster.local
```

Exit the Pod shell:

```sh
exit
```

### Verify DNS results

- The Service DNS lookup should resolve to the same ClusterIP shown by `kubectl get service web-app-clusterip`.
- The built-in Kubernetes name should also resolve if cluster DNS is functioning.
- A successful DNS lookup proves name resolution; a successful HTTP request additionally tests the Service-to-Pod traffic path.

### DNS troubleshooting note

A DNS test must be run from the environment whose DNS behavior is being investigated.

- On an Ubuntu host, `/etc/resolv.conf` may show `nameserver 127.0.0.53`. This is commonly the `systemd-resolved` local stub resolver.
- That host resolver is **not** the Kubernetes CoreDNS Service. A host-side lookup that returns `REFUSED` does not, by itself, prove that CoreDNS inside the cluster is broken.
- Inspect DNS from inside a Pod using `kubectl exec` or a dedicated debug Pod.

If the short-name lookup fails, collect evidence before changing cluster networking:

```bash
# Run on the machine where kubectl is configured.
kubectl get service web-app-clusterip -n default
kubectl get pods -n kube-system -o wide
kubectl get service kube-dns -n kube-system
kubectl get endpointslices \
  -l kubernetes.io/service-name=web-app-clusterip
```

For an interactive diagnostic Pod that remains available while troubleshooting:

```bash
kubectl run dns-debug \
  --image=busybox:1.36 \
  --restart=Never \
  --command -- sleep 3600

kubectl wait \
  --for=condition=Ready \
  pod/dns-debug \
  --timeout=90s

kubectl exec -it dns-debug -- sh
```

Inside `dns-debug`:

```sh
cat /etc/resolv.conf
nslookup kubernetes.default.svc.cluster.local
nslookup web-app-clusterip.default.svc.cluster.local
wget -T 5 -qO- http://web-app-clusterip
```

After collecting the output:

```sh
exit
```

Remove the diagnostic Pod when it is no longer needed:

```bash
kubectl delete pod dns-debug
```

**Troubleshooting discipline:** Do not edit the host's `/etc/resolv.conf`, restart CoreDNS, or delete networking resources until the in-Pod DNS tests and CoreDNS status identify a specific cause.

---

## 6. Task 4 - Expose the Application with NodePort

### Goal

- Expose the Service on a port on each Kubernetes node.
- Allow a client that can reach a node address and the configured port to access the application.

### File: `nodeport-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080
```

### Apply and inspect

```bash
kubectl apply -f nodeport-service.yaml
kubectl get service web-app-nodeport -o wide
kubectl describe service web-app-nodeport
kubectl get nodes -o wide
```

- `nodePort: 30080` is within Kubernetes' default NodePort range of `30000-32767`.
- The NodePort is opened on each node; traffic is directed through the Service to an eligible backend Pod.
- The NodePort range can be changed by cluster configuration.

### Traffic path

```text
Client
  |
  v
<Node-IP>:30080
  |
  v
NodePort Service :80
  |
  +------> Nginx Pod :80
  +------> Nginx Pod :80
  +------> Nginx Pod :80
```

### Test from a machine that can reach a node

Replace `<NODE-IP>` with an actual reachable node address:

```bash
curl -i http://<NODE-IP>:30080
```

- A successful response should contain an HTTP response from Nginx.
- `kubectl get nodes -o wide` shows node addresses, but the address must be reachable from the machine running `curl`.
- In cloud environments, check routing, network ACLs, host firewalls, and security-group rules. Allow only the required trusted source range; do not open NodePort broadly to the internet for a learning test.
- On local clusters, the correct access method depends on the platform and its port mappings. Follow the cluster-specific method when a node IP is not directly reachable.

---

## 7. Task 5 - Expose the Application with LoadBalancer

### Goal

- Request an external load balancer through the cluster's cloud-provider or load-balancer integration.
- Understand that creating the Kubernetes Service object does not guarantee that an external load balancer will be provisioned.

### File: `loadbalancer-service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
```

### Apply and watch the Service

```bash
kubectl apply -f loadbalancer-service.yaml

# Watch EXTERNAL-IP / hostname provisioning.
kubectl get service web-app-loadbalancer --watch
```

Press `Ctrl + C` after observing the status, then inspect:

```bash
kubectl get service web-app-loadbalancer -o wide
kubectl describe service web-app-loadbalancer
```

### Interpret the result

- In a supported cloud environment, the load-balancer integration may provision an external IP address or hostname.
- On a local cluster without a load-balancer implementation, `EXTERNAL-IP` may remain `<pending>`.
- In AWS or another cloud, provisioning also depends on the cluster's load-balancer integration, permissions, subnet/network configuration, and provider-specific requirements.
- Do not treat `<pending>` as an application Pod failure. It indicates that an external load-balancer address has not been assigned.

### Important implementation detail

- A `LoadBalancer` Service normally receives a ClusterIP.
- Kubernetes commonly allocates a NodePort for a LoadBalancer Service as well, but this behavior can vary with the provider implementation and Service configuration (for example, `allocateLoadBalancerNodePorts`).
- Inspect the actual Service rather than assuming every cluster uses an identical implementation.

---

## 8. Task 6 – Compare the Service Types

Run:

```bash
kubectl get services -o wide
```

| Service type | Access path | Typical purpose |
|---|---|---|
| **ClusterIP** | Internal Service IP or DNS name | Pod-to-Service communication inside the cluster |
| **NodePort** | `<Node-IP>:<NodePort>` | Direct node-level access, often for labs or specific network designs |
| **LoadBalancer** | External IP or hostname when provisioned | External client access through a cloud or installed load-balancer implementation |

### Inspect each Service

```bash
kubectl describe service web-app-clusterip
kubectl describe service web-app-nodeport
kubectl describe service web-app-loadbalancer
```

### Compare the key properties

```bash
kubectl get services \
  web-app-clusterip \
  web-app-nodeport \
  web-app-loadbalancer \
  -o wide
```

For each Service, check:

- `TYPE`
- `CLUSTER-IP`
- `EXTERNAL-IP`
- `PORT(S)`
- `SELECTOR`

**Core distinction:** All three Services use the same Pod label selector in this lab. Their main difference is how clients reach the Service, not which application Pods they select.

---

## 9. Task 7 – Inspect Endpoints and Selector Matching

### Goal

- Confirm that each Service selects the intended Nginx Pods.
- Understand the relationship between Pod labels, Service selectors, and backend endpoints.

### Check Pod labels

```bash
kubectl get pods -l app=web-app --show-labels
```

### Check the Services' selectors and endpoints

```bash
kubectl describe service web-app-clusterip
kubectl get endpoints web-app-clusterip

kubectl describe service web-app-nodeport
kubectl get endpoints web-app-nodeport

kubectl describe service web-app-loadbalancer
kubectl get endpoints web-app-loadbalancer
```

### Inspect EndpointSlices

```bash
kubectl get endpointslices \
  -l kubernetes.io/service-name=web-app-clusterip

kubectl get endpointslices \
  -l kubernetes.io/service-name=web-app-nodeport

kubectl get endpointslices \
  -l kubernetes.io/service-name=web-app-loadbalancer
```

- A Service selector such as `app: web-app` matches Pods with the label `app=web-app`.
- Ready, matching Pods are represented as backend endpoints.
- An empty endpoint list usually means the Service has no eligible backends; investigate labels, namespace, and Pod readiness.
- EndpointSlices are the modern API for representing Service backends. `kubectl get endpoints` remains a convenient compatibility view for this lab.

### Optional failure simulation (only after successful connectivity)

This test deliberately reduces the application to two replicas. It is optional and should be performed only when you are ready to observe controller behavior.

```bash
kubectl delete pod -l app=web-app --wait=false
kubectl get pods -l app=web-app -o wide --watch
```

- The Deployment/ReplicaSet should work toward maintaining the requested replica count.
- Stop watching with `Ctrl + C`.
- Verify the replica count again:

```bash
kubectl get deployment web-app
kubectl get pods -l app=web-app -o wide
kubectl get endpoints web-app-clusterip
```

- The replacement Pod may receive a different IP.
- The Service name and ClusterIP should remain stable while the Service object exists.

---

## 10. Task 8 – Clean Up the Lab

Delete the three Services and the Deployment:

```bash
kubectl delete -f clusterip-service.yaml
kubectl delete -f nodeport-service.yaml
kubectl delete -f loadbalancer-service.yaml
kubectl delete -f app-deployment.yaml
```

Delete any diagnostic Pod that was left running:

```bash
kubectl delete pod dns-debug --ignore-not-found
kubectl delete pod dns-test --ignore-not-found
kubectl delete pod test-client --ignore-not-found
```

Verify cleanup:

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

- The `web-app` Deployment and its Pods should be gone.
- The three custom Services should be gone.
- The built-in `kubernetes` Service in the `default` namespace should normally remain.
- Do not delete unrelated workloads or Services that existed before this lab.

---

## 11. Useful Commands Reference

```bash
# Workload status
kubectl get deployment web-app
kubectl rollout status deployment/web-app
kubectl get replicasets -l app=web-app
kubectl get pods -l app=web-app -o wide

# Labels and selectors
kubectl get pods -l app=web-app --show-labels
kubectl describe service web-app-clusterip

# Services and backends
kubectl get services -o wide
kubectl get endpoints web-app-clusterip
kubectl get endpointslices \
  -l kubernetes.io/service-name=web-app-clusterip

# DNS components
kubectl get pods -n kube-system -o wide
kubectl get service kube-dns -n kube-system

# Logs for CoreDNS (use a real Pod name from the previous command)
kubectl logs -n kube-system <coredns-pod-name>

# Apply all manifests in the current directory
kubectl apply -f .

# Remove the lab resources using their manifests
kubectl delete -f clusterip-service.yaml
kubectl delete -f nodeport-service.yaml
kubectl delete -f loadbalancer-service.yaml
kubectl delete -f app-deployment.yaml
```

---

## 14. Key Takeaways

- Pod IPs are not stable application endpoints; Services provide a stable way to reach selected Pods.
- Deployments manage replica count; Services provide network access to matching Pods.
- Service selectors must match the labels on the intended Pods.
- `port` is the Service-facing port; `targetPort` is the backend Pod port.
- `ClusterIP` is intended for internal cluster communication.
- `NodePort` exposes the Service through a port on each node.
- `LoadBalancer` requests external load-balancer provisioning when the cluster supports it.
- Kubernetes DNS allows clients to use Service names instead of hard-coded Service IPs.
- EndpointSlices represent the backend endpoints associated with a Service.
- A successful `kubectl apply` only confirms that the API accepted a resource; connectivity must be tested separately.

---


`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham` `#Kubernetes` `#DevOps`
