# Day 51 – Kubernetes Manifests and Your First Pods

## Task

For this exercise, I defined standalone Kubernetes Pods with YAML manifests and deployed them to my cluster. I used Nginx to test a web-serving container, BusyBox and Alpine to examine how a container's main process affects its lifetime, and Redis to create a Pod directly from the command line. I also explored generated manifests, validation, labels, resource inspection, and Pod deletion.

---

## The Four Required Fields of a Kubernetes Manifest

A Kubernetes manifest identifies the resource to create and describes the configuration Kubernetes should work toward. The four main top-level fields are:

| Field | Purpose |
|---|---|
| `apiVersion` | Specifies the API version used to define the resource. A Pod uses the core API version `v1`. |
| `kind` | States which Kubernetes object is being described. The resources in this exercise use `Pod`. |
| `metadata` | Supplies the object's name and optional information such as labels and annotations. |
| `spec` | Defines the requested configuration. For these Pods, this includes the container image, container name, ports, and startup command where required. |

A minimal example is:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sample-pod
spec:
  containers:
    - name: web
      image: nginx:latest
```

---

# Task 1: First Pod – Nginx

## Manifest: `nginx-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

I submitted the manifest to the cluster with:

```bash
kubectl apply -f nginx-pod.yaml
```

I checked the Pod and its placement using:

```bash
kubectl get pods
kubectl get pods -o wide
```

To inspect its configuration, state, and recent events:

```bash
kubectl describe pod nginx-pod
```

Container output can be read with:

```bash
kubectl logs nginx-pod
```

I opened a shell in the container with:

```bash
kubectl exec -it nginx-pod -- /bin/sh
```

From inside the container, I tested the web server with:

```bash
curl http://localhost:80
```

The Nginx image may not include `curl`. When it is unavailable inside the container, I can test the same endpoint from my machine using port forwarding. In one terminal:

```bash
kubectl port-forward pod/nginx-pod 8080:80
```

In another terminal:

```bash
curl -i http://localhost:8080
```

A successful request returns an HTTP response containing the default Nginx page. The `containerPort` entry documents the port used by the container; it does not by itself publish that port outside the Pod.

---

# Task 2: Custom Pod – BusyBox

## Manifest: `busybox-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev
spec:
  containers:
    - name: busybox
      image: busybox:latest
      command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

I created the BusyBox Pod with:

```bash
kubectl apply -f busybox-pod.yaml
```

I checked its state and read the message printed at startup:

```bash
kubectl get pods
kubectl logs busybox-pod
```

The expected log entry is:

```text
Hello from BusyBox
```

### Why does this Pod use a startup command?

BusyBox provides small command-line utilities rather than starting a persistent service by default. The `echo` command writes a message to standard output and then finishes. The following `sleep 3600` process keeps the container's main process active for the duration of the exercise, giving me time to inspect the Pod and enter its container.

I can open a shell and inspect running processes with:

```bash
kubectl exec -it busybox-pod -- /bin/sh
ps
exit
```

A container that exits is subject to the Pod's restart policy. With the default `Always` policy, Kubernetes attempts to restart the container; repeated rapid exits can lead to a `CrashLoopBackOff` state.

---

# Task 3: Third Pod – Alpine

I used Alpine for the third manifest and assigned three labels so I could practice selecting Pods by application, environment, and team.

## Manifest: `alpine-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine-pod
  labels:
    app: alpine
    environment: dev
    team: platform
spec:
  containers:
    - name: alpine
      image: alpine:latest
      command: ["sh", "-c", "echo Hello from Alpine && sleep 3600"]
```

I deployed and checked it with:

```bash
kubectl apply -f alpine-pod.yaml
kubectl get pods --show-labels
```

The startup command prints a message and keeps the container active. The labels give the Pod searchable metadata that can be used by Kubernetes selectors.

---

# Task 4: Imperative vs Declarative

Kubernetes supports creating resources by issuing a direct command or by applying a file that records the intended configuration.

## Imperative approach

I created a Redis Pod from the terminal without first writing a manifest:

```bash
kubectl run redis-pod --image=redis:latest
```

I then inspected the resource returned by the API server:

```bash
kubectl get pod redis-pod -o yaml
```

To retain a copy of the live object's YAML for comparison:

```bash
kubectl get pod redis-pod -o yaml > redis-pod-live.yaml
```

## Declarative approach

For the Nginx, BusyBox, and Alpine Pods, I described the requested configuration in YAML files and applied those files:

```bash
kubectl apply -f nginx-pod.yaml
kubectl apply -f busybox-pod.yaml
kubectl apply -f alpine-pod.yaml
```

### Comparison

| Imperative | Declarative |
|---|---|
| A command states the action and its parameters. | A manifest records the resource configuration to be applied. |
| Convenient for quick, one-off resource creation. | Convenient for repeatable changes and configuration review. |
| The command itself contains the creation settings. | The YAML file can be stored and reviewed in version control. |
| Example: `kubectl run redis-pod --image=redis:latest` | Example: `kubectl apply -f nginx-pod.yaml` |

The live YAML can include fields maintained by Kubernetes, such as a UID, resource version, creation timestamp, and status. These server-managed details are different from the concise configuration I wrote for the desired state.

---

# Task 5: Generate YAML with Dry Run

I used `kubectl run` in client dry-run mode to print a Pod manifest without creating the Pod:

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

I saved the generated output so it could be compared with my handwritten manifest:

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml > test-pod.yaml
```

The generated resource has the same basic structure as the manifest I wrote:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
    - name: test-pod
      image: nginx
```

The exact output can differ between `kubectl` versions and may include additional defaulted fields. My handwritten Nginx manifest also sets an application label and documents container port `80`. Client dry-run output is a useful starting point, but it should be checked and adjusted before it is used as a project manifest.

I compared the files with:

```bash
diff -u nginx-pod.yaml test-pod.yaml || true
```

---

# Task 6: Validate Before Applying

I checked the Nginx manifest without creating or changing the resource.

### Client-side dry run

```bash
kubectl apply -f nginx-pod.yaml --dry-run=client
```

This performs client-side checks and prints what would be applied without persisting the object.

### Server-side dry run

```bash
kubectl apply -f nginx-pod.yaml --dry-run=server
```

This sends the request to the Kubernetes API server for validation and admission processing, while asking the server not to save the object.

### Testing an incomplete manifest

I used a separate file to test the validation response when a container image is omitted.

Example `bad-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: missing-image-pod
spec:
  containers:
    - name: nginx
```

I checked it without creating the resource:

```bash
kubectl apply -f bad-pod.yaml --dry-run=server
```

The API validation should report that `spec.containers[0].image` is required. The precise wording may vary with the Kubernetes version. I kept this invalid manifest separate and did not apply it as a normal workload.

---

# Task 7: Pod Labels and Filtering

Labels are key-value attributes attached to Kubernetes objects. I used them to distinguish Pods and retrieve matching resources.

Display Pods with their labels:

```bash
kubectl get pods --show-labels
```

Select the Nginx Pod by application:

```bash
kubectl get pods -l app=nginx
```

Select development Pods:

```bash
kubectl get pods -l environment=dev
```

Select the Pod assigned to the platform team:

```bash
kubectl get pods -l team=platform
```

I also changed a label on the existing Nginx Pod:

```bash
kubectl label pod nginx-pod environment=production
```

I checked the updated labels and removed the temporary label afterwards:

```bash
kubectl get pods --show-labels
kubectl label pod nginx-pod environment-
```

A selector with more than one equality condition, for example `-l app=alpine,team=platform`, returns only resources matching every condition.

---

# Task 8: Pod Inspection Commands

I used the following commands to review resource state, scheduling details, events, container output, and the container environment:

```bash
# Display Pods in the current namespace
kubectl get pods

# Include Pod IP and node information
kubectl get pods -o wide

# Include label values
kubectl get pods --show-labels

# Inspect configuration, state, and events
kubectl describe pod nginx-pod

# Read container stdout and stderr
kubectl logs nginx-pod

# Start a shell in the container
kubectl exec -it nginx-pod -- /bin/sh

# View the Redis resource as YAML
kubectl get pod redis-pod -o yaml
```

The `describe` output is useful when a Pod is not reaching the expected state because its events can reveal image-pull, scheduling, or container-start problems. Logs show the output produced by the container process, while `exec` provides an interactive way to investigate a running container.

---

# Task 9: Clean Up

After capturing the running-Pod evidence, I removed the resources created for this exercise.

Delete the Pods created from manifests:

```bash
kubectl delete -f nginx-pod.yaml
kubectl delete -f busybox-pod.yaml
kubectl delete -f alpine-pod.yaml
```

Delete the Redis Pod created with `kubectl run`:

```bash
kubectl delete pod redis-pod
```

Confirm that the exercise Pods have been removed:

```bash
kubectl get pods
```

### What happens when a standalone Pod is deleted?

Deleting a standalone Pod removes that Pod object. Because no Deployment, ReplicaSet, or other workload controller owns it, Kubernetes has no controller responsible for creating a replacement. A container restart policy applies while the Pod still exists; it does not recreate a Pod resource after that resource has been deleted.

This is why Deployments are generally used to manage replicated, replaceable application workloads. They provide a controller that works to keep the requested number of Pods available.

---

# Key Takeaways

- A manifest describes a Kubernetes object's requested configuration.
- `apiVersion`, `kind`, `metadata`, and `spec` form the basic structure of the manifests used here.
- A Pod provides the execution environment for one or more closely associated containers.
- `kubectl apply -f` applies a resource configuration from a file.
- `kubectl run` can create a Pod directly from command-line arguments.
- Client dry-run output can be used as a starting point for a YAML manifest.
- Server-side dry run asks the API server to validate a request without saving it.
- A container needs an appropriate running process to remain active.
- Labels and selectors make it possible to organize and query Kubernetes resources.
- `kubectl describe`, `kubectl logs`, and `kubectl exec` provide different views for investigating a Pod.
- Deleting an unmanaged standalone Pod does not cause Kubernetes to create a replacement.

# Learn in Public

Today I moved from reading Kubernetes configuration to defining and inspecting Pods in my own cluster. I deployed Nginx, BusyBox, and Alpine, created Redis from the command line, tested manifest validation, and used labels to find specific workloads. The exercise also made the difference between a container restarting inside a Pod and a deleted standalone Pod being recreated much clearer.

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
