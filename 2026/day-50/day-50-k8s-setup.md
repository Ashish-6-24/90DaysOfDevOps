# Day 50 Kubernetes Architecture and Local Cluster

## Goal

- Understand why container orchestration is needed beyond running containers with Docker.
- Identify the responsibilities of the Kubernetes control plane and node-level services.
- Prepare a local cluster with **kind (Kubernetes in Docker)**.
- Use `kubectl` to inspect cluster health, system workloads, and configuration.

## 1. Kubernetes: Background and Purpose

- **Why it was developed:** Docker simplifies packaging and launching containers, but coordinating a large number of containers across several machines introduces scheduling, scaling, networking, and recovery work. Kubernetes was developed to automate that coordination and keep applications operating according to their declared state.
- **What it manages:** Kubernetes places workloads on suitable nodes, supports application scaling, provides service discovery and networking, and replaces or restarts workloads when recovery is possible.
- **Origin:** Google developed Kubernetes and released it as an open-source project in 2014. Its design drew on **Borg**, Google's internal system for managing workloads across large groups of machines.
- **Name:** The Greek-derived word *Kubernetes* means **helmsman** or **pilot**. The shorthand **k8s** keeps the first and last letters and uses `8` for the eight letters between them.

## 2. Kubernetes Architecture

### Cluster overview

```text
                         KUBERNETES CLUSTER

      +---------------------------------------------------+
      |                    CONTROL PLANE                  |
      |                                                   |
      |  +------------------+       +------------------+  |
      |  |   API Server     |<----->|       etcd       |  |
      |  +--------+---------+       +------------------+  |
      |           ^                                       |
      |           |                                       |
      |  +--------+---------+       +------------------+  |
      |  |    Scheduler     |       | Controller Mgr.  |  |
      |  +------------------+       +------------------+  |
      +---------------------------+-----------------------+
                                  |
                     communicates with node agents
                                  |
             +--------------------+--------------------+
             |                                         |
      +------v----------------+               +--------v---------------+
      |       WORKER NODE     |               |      WORKER NODE       |
      |                       |               |                        |
      |  kubelet              |               |  kubelet               |
      |  kube-proxy           |               |  kube-proxy            |
      |  Container Runtime    |               |  Container Runtime     |
      |       |               |               |       |                |
      |      Pods             |               |      Pods              |
      +-----------------------+               +------------------------+
```

### Control plane responsibilities

- **API Server:** Receives Kubernetes API requests, including requests sent through `kubectl`.
- **etcd:** Keeps the cluster's persisted configuration and state in a key-value data store.
- **Scheduler:** Finds an appropriate node for a Pod that has not yet been assigned to one.
- **Controller Manager:** Runs control loops that compare actual resources with the requested state and work to close any difference.

### Node responsibilities

- **kubelet:** Runs on each node, observes the Pod instructions assigned to that node, and works with the container runtime to keep them running.
- **kube-proxy:** Maintains network rules used by Kubernetes Services to reach Pods.
- **Container Runtime:** Starts and manages containers. Examples include `containerd` and `CRI-O`.
- **Pod:** The basic unit Kubernetes schedules. A Pod contains one or more containers that share its execution context.

### Request path: `kubectl apply -f pod.yaml`

1. `kubectl` sends the manifest to the API Server.
2. The API Server processes the request and records the requested resource state in `etcd`.
3. The Scheduler notices that the new Pod has no node assignment and selects a suitable node.
4. The kubelet on that node observes the assignment and asks the container runtime to start the containers.
5. The runtime launches the containers, and Kubernetes components continue working toward the declared state.

### Failure scenarios

- **API Server unavailable:** New API requests and most cluster-management changes cannot be processed. Containers already running may continue under the node's kubelet and runtime, but the control plane cannot accept normal changes or make its usual scheduling decisions until the API Server is restored.
- **Worker node unavailable:** The control plane detects that the node is not responding. Pods managed by higher-level controllers, such as Deployments, may be recreated on healthy nodes when capacity and configuration allow. Workloads on the failed node are unavailable until recovery or replacement occurs.

## 3. Install the Kubernetes CLI

The commands below are for a Linux machine with the `amd64` architecture.

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Confirm that the client is available:

```bash
kubectl version --client
which kubectl
```

## 4. Create a Local Cluster with kind

### Tool selection

- **Selected option:** kind (Kubernetes in Docker).
- **Reason:** It uses Docker containers as Kubernetes nodes, so it fits naturally with the container workflow already used in this DevOps practice.

### Install kind on Linux

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Create and check the cluster

```bash
kind create cluster --name devops-cluster
kubectl cluster-info
kubectl get nodes
kubectl get nodes -o wide
```

> **Record the real result:** Add the actual command output and screenshots after running these commands. Do not replace this evidence with sample output.

## 5. Inspect Cluster Resources

Run the following commands after the cluster is available:

```bash
# Show the API endpoints for the active cluster
kubectl cluster-info

# Display registered nodes
kubectl get nodes

# Inspect one node (replace the value with the name returned above)
kubectl describe node <node-name>

# Display namespaces
kubectl get namespaces

# Display Pods from every namespace
kubectl get pods -A

# Focus on Kubernetes system workloads
kubectl get pods -n kube-system
```

### Common `kube-system` components

Pod names may include generated suffixes. Match the component name rather than expecting every Pod name to be identical.

| Component / Pod name | Role |
|---|---|
| `kube-apiserver` | Accepts and processes requests to the Kubernetes API. |
| `etcd` | Persists cluster state and configuration. |
| `kube-scheduler` | Chooses nodes for Pods that have not been scheduled. |
| `kube-controller-manager` | Runs controllers that reconcile resources toward their declared state. |
| `kube-proxy` | Maintains Service-related networking rules on nodes. |
| `coredns` | Provides DNS name resolution and service discovery inside the cluster. |

### Connect the running Pods to the architecture

- `kube-apiserver` → API Server
- `etcd` → Cluster state store
- `kube-scheduler` → Scheduler
- `kube-controller-manager` → Controller Manager
- `kube-proxy` → Node networking
- `coredns` → Cluster DNS

## 6. Cluster Lifecycle and kubectl Contexts

### Remove and recreate the kind cluster

```bash
kind delete cluster --name devops-cluster
kind create cluster --name devops-cluster
kubectl get nodes
```

### Check the active cluster context

```bash
# Show the context currently used by kubectl
kubectl config current-context

# List configured contexts
kubectl config get-contexts

# Inspect the kubeconfig settings
kubectl config view

# List kind clusters
kind get clusters
```

For this cluster name, kind normally creates the context `kind-devops-cluster`.

### kubeconfig notes

- A **kubeconfig** file gives `kubectl` the connection details and identity information needed to communicate with a cluster.
- It can include API server details, certificate information, user credentials, and named contexts.
- The usual Linux location is `~/.kube/config`.
- The current context determines which configured cluster and user settings `kubectl` uses by default.


## 8. Commands Reference

```bash
kubectl version --client
kubectl cluster-info
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node <node-name>
kubectl get namespaces
kubectl get pods -A
kubectl get pods -n kube-system
kubectl config current-context
kubectl config get-contexts
kubectl config view
kind get clusters
kind delete cluster --name devops-cluster
kind create cluster --name devops-cluster
```

## 9. Key Learnings

- Docker packages and runs containers; Kubernetes coordinates containerized workloads across a cluster.
- The API Server is the main interface for cluster operations, while `etcd` stores the persisted cluster state.
- The Scheduler assigns Pods to nodes, and controllers work continuously to reconcile resources.
- The kubelet and container runtime handle Pod execution on each node; kube-proxy maintains Service networking rules.
- `kubectl` communicates with the cluster using the active context in the kubeconfig file.
- kind provides a local Kubernetes environment by running cluster nodes as Docker containers.

## Learn in Public

Started learning Kubernetes by exploring its architecture and preparing a local cluster with kind. The focus was on understanding how the control plane coordinates workloads, how node components run Pods, and how `kubectl` is used to inspect cluster resources.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
