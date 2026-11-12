# Day 57 - Kubernetes Resource Management and Health Probes

## Overview

- Configured CPU and memory requirements for Kubernetes workloads.
- Examined how resource allocation influences Pod scheduling and container execution.
- Investigated memory exhaustion through an intentional `OOMKilled` scenario.
- Created an unschedulable Pod to understand scheduler resource constraints.
- Implemented Kubernetes health-check mechanisms using liveness, readiness, and startup probes.
- Observed how Kubernetes responds to unhealthy containers and controls application traffic.
- Practiced workload recovery and resource-management troubleshooting.


## Resource Allocation vs Application Health

- **Resource Requests**
  - Define the CPU and memory requirements used by the Kubernetes scheduler.
  - Help determine whether a node can accommodate a workload.
  - Do not represent a fixed maximum consumption boundary.

- **Resource Limits**
  - Establish the maximum CPU and memory consumption permitted for a container.
  - CPU consumption can be restricted through throttling.
  - Memory consumption beyond the enforced limit can result in container termination.

- **QoS Classification**
  - `Guaranteed`: Every container has matching CPU and memory requests and limits.
  - `Burstable`: At least one resource request or limit is configured, but the Pod does not qualify for Guaranteed.
  - `BestEffort`: No CPU or memory requests or limits are specified for any container.

- **Health Monitoring**
  - Liveness checks detect containers that need restarting.
  - Readiness checks determine whether workloads should receive Service traffic.
  - Startup checks provide additional initialization time before other configured health checks become active.




## Task 1 – CPU and Memory Allocation

- Created a Pod manifest with explicitly defined resource requirements.
- Configured CPU requests to `100m` and CPU limits to `250m`.
- Assigned `128Mi` memory as the request and `256Mi` as the limit.
- Deployed the workload using `kubectl apply`.
- Inspected the resource configuration through `kubectl describe pod`.
- Verified the resulting QoS classification as `Burstable`.
- Confirmed the configured values through JSONPath queries.

**Key Observations:**
- Resource requests influence scheduling decisions.
- Resource limits establish runtime consumption boundaries.
- Different request and limit values resulted in a Burstable classification.

## Task 2 – Memory Exhaustion and OOMKilled

- Deployed a stress-testing container using `polinux/stress`.
- Restricted its memory consumption to `100Mi`.
- Configured the stress process to allocate `200M` of memory.
- Monitored container termination and subsequent restart behavior.
- Inspected termination details using `kubectl describe pod`.
- Identified `OOMKilled` as the termination reason.
- Examined exit code `137`, associated with termination through `SIGKILL`.

**Key Observations:**
- Memory limits are enforced at the container level.
- Exceeding the available memory allowance can trigger an OOM kill.
- Kubernetes can restart the terminated container according to its restart policy.

## Task 3 – Scheduling Failure and Pending Pods

- Defined a Pod requesting `100` CPU cores and `128Gi` of memory.
- Submitted the workload to the Kubernetes API server.
- Examined the resulting Pod condition using `kubectl get pods`.
- Investigated scheduling errors through the Pod's Events section.
- Identified `FailedScheduling` as the relevant scheduling event.
- Examined resource availability on the cluster nodes.

**Key Observations:**
- The scheduler evaluates resource requests before assigning workloads to nodes.
- Insufficient CPU or memory capacity prevents successful placement.
- A Pod can remain in the Pending phase until suitable resources become available.

## Task 4 – Liveness Probe

- Deployed a BusyBox container with an execution-based health check.
- Created `/tmp/healthy` during container initialization.
- Configured the application simulation to remove the health indicator after 30 seconds.
- Implemented an `exec` probe using `cat /tmp/healthy`.
- Set the checking interval to five seconds.
- Configured three consecutive failures as the restart threshold.
- Monitored container recovery through `kubectl get pod -w`.
- Inspected probe failures and restart events.

**Key Observations:**
- Liveness checks identify containers that are no longer functioning as expected.
- Repeated unsuccessful checks trigger container restarts.
- Kubernetes attempts to restore the workload without requiring manual Pod recreation.

## Task 5 – Readiness Probe

- Deployed an Nginx container with an HTTP-based readiness check.
- Configured the health endpoint using `/` on port `80`.
- Exposed the workload through a Service named `readiness-svc`.
- Verified the initial Pod IP registration in Service endpoints.
- Removed the Nginx homepage to simulate an application-level failure.
- Observed the Pod transition from `1/1` to `0/1` Ready.
- Examined the Service endpoint changes.
- Verified that the container remained running without an additional restart.

**Key Observations:**
- Readiness checks determine whether a workload can accept incoming traffic.
- Unready Pods are excluded from the Service's ready endpoints.
- Readiness failures do not independently restart containers.

## Task 6 – Startup Probe

- Deployed a BusyBox workload simulating a 20-second initialization period.
- Created `/tmp/started` after the initialization command completed.
- Configured a startup probe using an execution-based health check.
- Set the checking interval to five seconds.
- Established a failure threshold of twelve attempts.
- Added a liveness probe to monitor the application after initialization.
- Examined startup completion through container logs and filesystem inspection.
- Investigated the consequences of reducing the startup failure threshold to two.

**Key Observations:**
- Startup checks protect applications that require additional initialization time.
- Configured liveness and readiness checks remain inactive until startup succeeds.
- An insufficient startup failure allowance can terminate applications before initialization completes.

## Task 7 – Resource Cleanup

- Removed the Pods created during the exercises.
- Deleted the Service associated with the readiness demonstration.
- Verified the removal of the temporary workloads.
- Checked the cluster for remaining resources from the experiment.

**Cleanup Commands:**

```bash
kubectl delete pod resource-demo oom-demo pending-demo \
  liveness-demo readiness-demo startup-demo \
  --ignore-not-found

kubectl delete service readiness-svc \
  --ignore-not-found

kubectl get pods
kubectl get services
```

## Troubleshooting

- **Pod remains Pending**
  - Inspect `kubectl describe pod`.
  - Review scheduling events.
  - Check node allocatable resources and existing resource requests.

- **Container repeatedly gets OOMKilled**
  - Inspect the configured memory limit.
  - Review the container's termination reason and exit code.
  - Evaluate application memory requirements.

- **Liveness probe repeatedly fails**
  - Verify the probe command and file location.
  - Examine container logs.
  - Review initial delay, execution interval, and failure threshold.

- **Readiness probe fails**
  - Verify the HTTP endpoint and listening port.
  - Check the application's response.
  - Inspect Pod readiness conditions and Service endpoints.

- **Startup probe causes repeated restarts**
  - Review the application's actual initialization duration.
  - Increase the startup failure allowance when appropriate.
  - Check the startup command and health indicator.

## Key Takeaways

- Resource requests guide Kubernetes scheduling decisions.
- Resource limits control container resource consumption.
- CPU exhaustion generally results in throttling, whereas memory exhaustion can cause OOM termination.
- QoS classifications describe the resource configuration of Pods.
- Scheduling failures can occur when node capacity cannot satisfy workload requests.
- Liveness probes support automatic container recovery.
- Readiness probes help prevent traffic from reaching unprepared workloads.
- Startup probes accommodate applications requiring longer initialization periods.
- Correct probe configuration improves workload reliability and availability.
- Resource management and health monitoring are essential components of production Kubernetes operations.

## Reference

- [Kubernetes – Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Kubernetes – Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Kubernetes – Pod Quality of Service Classes](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/)
- [Kubernetes – Debugging Pods](https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/)

