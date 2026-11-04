# Day 52 - Kubernetes Namespaces and Deployments

## Task

- Explore Kubernetes namespaces and understand how they organize resources within a cluster.
- Create development, staging, and production namespaces.
- Run standalone Pods in separate namespaces.
- Create an Nginx Deployment with three replicas.
- Verify Deployment and ReplicaSet behavior.
- Test self-healing by deleting a Deployment-managed Pod.
- Scale the Deployment up and down using imperative and declarative methods.
- Perform a rolling update from Nginx `1.24` to `1.25` and roll back.
- Capture evidence and clean up the lab resources.

## Environment and Preflight Checks

- Record the environment used for this exercise:
  - Operating system: `<add your OS>`
  - Kubernetes context: `<add kubectl config current-context output>`
  - Kubernetes version: `<add kubectl version output>`
  - Nodes: `<add kubectl get nodes output>`

- Confirm the active context before making changes:

  ```bash
  kubectl config current-context
  kubectl get nodes -o wide
  ```

- Confirm that `kubectl` can communicate with the intended cluster.
- Use the correct namespace in every command; an omitted `-n` uses the current context's namespace, which is normally `default`.

## Task 1: Explore Default Namespaces

- List the namespaces:

  ```bash
  kubectl get namespaces
  ```

- Inspect Pods in the Kubernetes system namespace:

  ```bash
  kubectl get pods -n kube-system
  kubectl get pods -n kube-system -o wide
  ```

- Count Pods whose phase is `Running`:

  ```bash
  kubectl get pods -n kube-system \
    --field-selector=status.phase=Running \
    --no-headers | wc -l
  ```

- Understand the built-in namespaces:
  - `default`: namespace used when no namespace is specified in a command or resource manifest.
  - `kube-system`: contains Kubernetes system workloads and supporting components.
  - `kube-public`: intended for publicly readable cluster information.
  - `kube-node-lease`: contains Lease objects used for node heartbeat information.

- Record the actual number of running `kube-system` Pods: `<fill in from your cluster>`.
- Note that system Pods vary by Kubernetes distribution and cluster configuration.
- Do not modify or delete `kube-system` resources as part of this exercise.

## Task 2: Create and Use Custom Namespaces

- Create the development and staging namespaces:

  ```bash
  kubectl create namespace dev
  kubectl create namespace staging
  ```

- Create the production namespace from the supplied manifest:

  ```bash
  kubectl apply -f namespace.yml
  ```

- The `namespace.yml` file in this submission creates the `production` namespace:

  ```yaml
  apiVersion: v1
  kind: Namespace
  metadata:
    name: production
    labels:
      app.kubernetes.io/part-of: day-52-kubernetes-lab
      environment: production
  ```

- Verify all three custom namespaces:

  ```bash
  kubectl get namespaces
  ```

- Run one standalone Nginx Pod in `dev` and another in `staging`:

  ```bash
  kubectl run nginx-dev --image=nginx:latest -n dev
  kubectl run nginx-staging --image=nginx:latest -n staging
  ```

- Verify each namespace separately:

  ```bash
  kubectl get pods -n dev
  kubectl get pods -n staging
  ```

- Compare namespace-scoped and cluster-wide output:

  ```bash
  kubectl get pods
  kubectl get pods -A
  ```

- Key observations:
  - `kubectl get pods` displays Pods from the current namespace only.
  - `kubectl get pods -n dev` displays Pods from `dev` only.
  - `kubectl get pods -A` displays Pods across all namespaces.
  - Namespaces provide logical organization; they are not, by themselves, a complete security boundary.

## Task 3: Create the First Deployment

- Use the supplied `nginx-deployment.yaml` manifest.
- The manifest creates a Deployment named `nginx-deployment` in the `dev` namespace.
- The requested initial state is three Nginx replicas using `nginx:1.24`.
- The manifest also defines a readiness probe and a rolling-update strategy.

- Deployment manifest:

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: nginx-deployment
    namespace: dev
    labels:
      app: nginx
      app.kubernetes.io/part-of: day-52-kubernetes-lab
  spec:
    replicas: 3
    minReadySeconds: 5
    strategy:
      type: RollingUpdate
      rollingUpdate:
        maxSurge: 1
        maxUnavailable: 0
    selector:
      matchLabels:
        app: nginx
    template:
      metadata:
        labels:
          app: nginx
      spec:
        containers:
          - name: nginx
            image: nginx:1.24
            ports:
              - name: http
                containerPort: 80
                protocol: TCP
            readinessProbe:
              httpGet:
                path: /
                port: http
                scheme: HTTP
              periodSeconds: 5
              timeoutSeconds: 2
              failureThreshold: 3
  ```

- Optionally ask the API server to validate the manifest without creating the Deployment:

  ```bash
  kubectl apply --dry-run=server -f nginx-deployment.yaml
  ```

- Apply the Deployment:

  ```bash
  kubectl apply -f nginx-deployment.yaml
  ```

- Wait for the rollout and inspect the resources:

  ```bash
  kubectl rollout status deployment/nginx-deployment -n dev
  kubectl get deployments -n dev
  kubectl get pods -n dev -l app=nginx
  kubectl get replicasets -n dev
  ```

- Understand the main manifest fields:
  - `apiVersion: apps/v1`: API version for the Deployment resource.
  - `kind: Deployment`: declares the resource type.
  - `metadata.name`: names the Deployment.
  - `metadata.namespace`: places the Deployment in `dev`.
  - `replicas: 3`: declares the desired number of Pods.
  - `selector.matchLabels`: identifies the Pods managed by the Deployment.
  - `template`: defines the Pod blueprint used to create Pods.
  - `template.metadata.labels`: labels the Pods created from the template.
  - `containers`: defines the container or containers in each Pod.
  - `image: nginx:1.24`: selects the Nginx image tag.
  - `containerPort: 80`: documents the port used by the Nginx container.
  - `readinessProbe`: checks whether Nginx is ready to receive traffic.
  - `maxSurge: 1`: permits one additional Pod above the desired count during a rolling update.
  - `maxUnavailable: 0`: sets the allowed number of unavailable replicas during a rolling update to zero.
  - `minReadySeconds: 5`: requires a Pod to remain ready for five seconds before it is considered available.

- Important selector rule:
  - `spec.selector.matchLabels` must match `spec.template.metadata.labels`.
  - In this manifest, both use `app: nginx`.

- Understand the controller relationship:
  - Deployment: manages the application rollout and desired state.
  - ReplicaSet: maintains the requested number of matching Pods.
  - Pod: runs the Nginx container.

## Task 4: Test Self-Healing

- List the Pods managed by the Deployment:

  ```bash
  kubectl get pods -n dev -l app=nginx
  ```

- Select one of the Deployment-managed Pods:

  ```bash
  POD_TO_DELETE=$(kubectl get pods -n dev -l app=nginx \
    -o jsonpath='{.items[0].metadata.name}')
  echo "$POD_TO_DELETE"
  ```

- Delete the selected Pod:

  ```bash
  kubectl delete pod "$POD_TO_DELETE" -n dev
  ```

- Watch the ReplicaSet create a replacement:

  ```bash
  kubectl get pods -n dev -l app=nginx -w
  ```

- Stop watching with `Ctrl+C` after observing the replacement.
- Verify the Deployment returns to three ready replicas:

  ```bash
  kubectl get deployment nginx-deployment -n dev
  kubectl get pods -n dev -l app=nginx
  ```

- Record the deleted Pod name and replacement Pod name: `<fill in actual names>`.
- Expected behavior:
  - The replacement Pod normally has a different generated name because it is a new Pod object.
  - The ReplicaSet detects that the actual number of matching Pods is below the desired count.
  - The ReplicaSet creates a replacement Pod to reconcile the desired state.
- Compare the workload types:
  - Standalone Pod: deleting it removes that Pod; no Deployment or ReplicaSet exists to recreate it.
  - Deployment-managed Pod: the ReplicaSet replaces a deleted Pod to maintain the desired replica count.

## Task 5: Scale the Deployment

- Confirm the initial replica count:

  ```bash
  kubectl get deployment nginx-deployment -n dev
  ```

- Imperative scaling — scale up from three to five replicas:

  ```bash
  kubectl scale deployment nginx-deployment --replicas=5 -n dev
  kubectl get pods -n dev -l app=nginx
  kubectl get deployment nginx-deployment -n dev
  ```

- Wait until the requested replicas are ready before continuing.
- Imperative scaling — scale down from five to two replicas:

  ```bash
  kubectl scale deployment nginx-deployment --replicas=2 -n dev
  kubectl get pods -n dev -l app=nginx
  kubectl get deployment nginx-deployment -n dev
  ```

- Expected behavior:
  - Kubernetes terminates three excess Pods when the desired count changes from five to two.
  - The ReplicaSet reconciles the actual Pod count with the new desired count.

- Declarative scaling — edit the manifest:
  - Open `nginx-deployment.yaml`.
  - Change `spec.replicas` from `3` to `4`.
  - Save the file.
  - Apply the updated manifest:

  ```bash
  kubectl apply -f nginx-deployment.yaml
  kubectl get deployment nginx-deployment -n dev
  kubectl get pods -n dev -l app=nginx
  ```

- Important configuration note:
  - The supplied manifest initially contains `replicas: 3`.
  - Change it to `replicas: 4` before applying for the declarative scaling step.
  - Applying a manifest with `replicas: 3` after imperative scaling would set the desired count back to three.
- Compare the scaling approaches:
  - Imperative: `kubectl scale` changes the live desired replica count directly.
  - Declarative: editing YAML and applying it records the desired configuration in a file that can be version-controlled.

## Task 6: Perform a Rolling Update

- Confirm that the Deployment is using the original image:

  ```bash
  kubectl get deployment nginx-deployment -n dev \
    -o jsonpath='{.spec.template.spec.containers[0].image}'
  echo
  ```

- Update the Nginx container from `nginx:1.24` to `nginx:1.25`:

  ```bash
  kubectl set image deployment/nginx-deployment \
    nginx=nginx:1.25 -n dev
  ```

- Monitor the rollout:

  ```bash
  kubectl rollout status deployment/nginx-deployment -n dev
  ```

- Inspect the Deployment, Pods, and ReplicaSets:

  ```bash
  kubectl get deployment nginx-deployment -n dev
  kubectl get pods -n dev -l app=nginx
  kubectl get replicasets -n dev
  ```

- Verify the image in the Deployment:

  ```bash
  kubectl describe deployment nginx-deployment -n dev | grep Image
  ```

- Inspect revision history:

  ```bash
  kubectl rollout history deployment/nginx-deployment -n dev
  ```

- Expected behavior:
  - The Pod template changes when the image changes.
  - Kubernetes creates a new ReplicaSet for the updated template.
  - The old and new ReplicaSets are scaled during the rolling update.
  - With the configured readiness probe and rolling-update settings, Kubernetes waits for updated Pods to become available before completing the replacement process.
- Availability note:
  - A rolling update is designed to maintain availability, but a successful rollout alone does not prove end-to-end zero downtime.
  - Real application availability also depends on Services, traffic routing, readiness behavior, capacity, dependencies, and application health.
  - This lab does not create a Service or test external user traffic.

## Task 7: Roll Back the Deployment

- Return to the previous Deployment revision:

  ```bash
  kubectl rollout undo deployment/nginx-deployment -n dev
  ```

- Wait for the rollback to complete:

  ```bash
  kubectl rollout status deployment/nginx-deployment -n dev
  ```

- Verify the image:

  ```bash
  kubectl describe deployment nginx-deployment -n dev | grep Image
  ```

- Inspect the revision history again:

  ```bash
  kubectl rollout history deployment/nginx-deployment -n dev
  ```

- Expected result for this exercise:
  - The Deployment returns to the previous Pod template revision.
  - If the previous revision used `nginx:1.24`, the image should return to `nginx:1.24`.
  - Record the actual image reported by your cluster: `<fill in verified image>`.

## Deployment Status and Resource Inspection

- Inspect Deployment status:

  ```bash
  kubectl get deployments -n dev
  ```

- Understand the status columns:
  - `READY`: ready replicas compared with the desired replica count.
  - `UP-TO-DATE`: replicas updated to the latest Deployment configuration.
  - `AVAILABLE`: replicas currently available according to Deployment availability rules.
- Example of a fully available three-replica Deployment:

  ```text
  NAME               READY   UP-TO-DATE   AVAILABLE
  nginx-deployment   3/3     3            3
  ```

- The example is illustrative; record the values returned by your cluster.

## Resources Across Namespaces

- List Deployments across all namespaces:

  ```bash
  kubectl get deployments -A
  ```

- List Pods across all namespaces:

  ```bash
  kubectl get pods -A
  ```

- Inspect resources in one namespace:

  ```bash
  kubectl get deployments -n dev
  kubectl get pods -n dev
  kubectl get pods -n staging
  ```

- Remember:
  - A resource created in `dev` does not appear in a default-namespace query.
  - `-n <namespace>` selects one namespace.
  - `-A` or `--all-namespaces` queries all namespaces for namespaced resources.

## Evidence and Screenshots

- Capture the resource listings before cleanup.
- Create the screenshot directory if it does not exist:

  ```bash
  mkdir -p screenshots
  ```

- Capture terminal output showing Deployments and Pods across namespaces:

  ```bash
  kubectl get deployments -A -o wide
  kubectl get pods -A -o wide
  ```

- Save the screenshot as:
  - `screenshots/day-52-resources.png`
- Ensure the screenshot visibly shows:
  - The `dev` namespace and `nginx-deployment`.
  - The Deployment replica status.
  - The Deployment-managed Nginx Pods.
  - The standalone `nginx-dev` and `nginx-staging` Pods, if they are still present.
- Do not capture only the `default` namespace if the resources were created in `dev` or `staging`.
- Add the screenshot to Git before submitting.

## Cleanup

- Capture the required evidence before deleting resources.
- Delete the Deployment:

  ```bash
  kubectl delete deployment nginx-deployment -n dev
  ```

- Delete the standalone Pods:

  ```bash
  kubectl delete pod nginx-dev -n dev
  kubectl delete pod nginx-staging -n staging
  ```

- Delete the custom namespaces:

  ```bash
  kubectl delete namespace dev staging production
  ```

- Verify cleanup:

  ```bash
  kubectl get namespaces
  kubectl get pods -A
  kubectl get deployments -A
  ```

- Expected result:
  - The custom `dev`, `staging`, and `production` namespaces are removed.
  - Namespaced resources inside those namespaces are removed with them.
  - Kubernetes system namespaces remain.
- Caution:
  - Namespace deletion removes all namespaced resources inside the selected namespaces.
  - Confirm the cluster and namespace names before running deletion commands, especially outside a disposable lab.

## Useful Commands Learned

- List namespaces:

  ```bash
  kubectl get namespaces
  ```

- List Pods in a namespace:

  ```bash
  kubectl get pods -n dev
  ```

- List Pods and Deployments across namespaces:

  ```bash
  kubectl get pods -A
  kubectl get deployments -A
  ```

- Create namespaces:

  ```bash
  kubectl create namespace dev
  kubectl create namespace staging
  ```

- Apply manifests:

  ```bash
  kubectl apply -f namespace.yml
  kubectl apply -f nginx-deployment.yaml
  ```

- Inspect Deployments and ReplicaSets:

  ```bash
  kubectl get deployments -n dev
  kubectl get replicasets -n dev
  ```

- Scale a Deployment:

  ```bash
  kubectl scale deployment nginx-deployment --replicas=5 -n dev
  ```

- Update a container image:

  ```bash
  kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
  ```

- Inspect rollout status and history:

  ```bash
  kubectl rollout status deployment/nginx-deployment -n dev
  kubectl rollout history deployment/nginx-deployment -n dev
  ```

- Roll back a Deployment:

  ```bash
  kubectl rollout undo deployment/nginx-deployment -n dev
  ```

## Key Takeaways

- Namespaces organize namespaced Kubernetes resources within a cluster.
- `kubectl get pods` checks the current namespace; `kubectl get pods -A` checks all namespaces.
- A Deployment declares the desired state for an application workload.
- A Deployment manages ReplicaSets, and ReplicaSets maintain the requested number of Pods.
- Deleting a Deployment-managed Pod causes its ReplicaSet to create a replacement.
- Scaling changes the desired replica count and Kubernetes reconciles the actual count.
- Declarative manifests make desired configuration reviewable and version-controllable.
- Rolling updates progressively replace Pods when the Pod template changes.
- Rollback returns a Deployment to a previous revision of its Pod template.
- Namespace deletion removes the namespaced resources contained within that namespace.
- Namespaces provide logical organization, not complete security isolation by themselves.
