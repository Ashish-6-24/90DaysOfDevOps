# Day 58 - Metrics Server and Horizontal Pod Autoscaler (HPA)

## Goal

Understand how Kubernetes monitors live resource consumption and automatically adjusts application replicas based on CPU demand using Horizontal Pod Autoscaling.

## What I Covered

### 1. Metrics Server Installation
- Deployed Metrics Server on a local Kind cluster.
- Enabled Kubernetes resource metrics collection.
- Addressed local kubelet TLS verification requirements.
- Verified Metrics Server availability through the Kubernetes Metrics API.

### 2. Resource Monitoring
- Used `kubectl top nodes` to inspect node-level CPU and memory consumption.
- Used `kubectl top pods -A` to monitor workloads across namespaces.
- Sorted Pods by CPU and memory consumption.
- Compared actual resource usage against configured requests and limits.

### 3. Application Deployment
- Deployed the PHP-Apache sample application using `registry.k8s.io/hpa-example`.
- Configured a CPU request of **200m**.
- Exposed the Deployment through a ClusterIP Service.
- Verified Pod health and resource configuration.

### 4. Imperative Autoscaling
- Created an HPA using `kubectl autoscale`.
- Configured a CPU utilization target of **50%**.
- Defined scaling boundaries between **1 and 10 replicas**.
- Inspected HPA metrics, conditions, replica counts, and scaling events.

### 5. Load Testing and Autoscaling
- Generated continuous HTTP requests against the application.
- Observed CPU utilization through the HPA.
- Monitored automatic replica increases under sustained load.
- Stopped traffic and examined the scale-down behavior.

### 6. Declarative HPA Configuration
- Recreated the autoscaler using the `autoscaling/v2` API.
- Configured CPU utilization targeting at **50%**.
- Defined custom scaling behavior:
  - Scale-up stabilization: **0 seconds**.
  - Scale-down stabilization: **300 seconds**.
- Applied and inspected the declarative configuration.

### 7. Resource Cleanup
- Removed the practice HPA, Service, Deployment, and load-generator Pod.
- Retained Metrics Server for subsequent Kubernetes exercises.

## Key Takeaway

Metrics Server makes live resource consumption available to Kubernetes, while HPA uses that information to maintain the desired application capacity. Understanding CPU requests, utilization targets, and scaling behavior is essential for building workloads that respond efficiently to changing traffic without unnecessary resource consumption.
