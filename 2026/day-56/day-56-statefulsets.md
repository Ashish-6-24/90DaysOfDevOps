# Day 56 | Managing Stateful Workloads with Kubernetes StatefulSets

> **90 Days of DevOps** | Consistent replica identity, discoverable network endpoints, and storage that outlives a pod.

## Why This Lab Matters

- Stateless workloads can usually replace one replica with another without preserving its identity.
- Stateful systems may depend on predictable member names, individual storage, and reliable peer discovery.
- This lab uses Nginx as a simple workload to explore StatefulSet behavior without introducing database-specific configuration.
- The practical focus is on ordinal pod names, per-pod DNS records, one PersistentVolumeClaim (PVC) per replica, recovery after pod replacement, and controlled replica changes.
- Kubernetes resource manifests and terminal evidence should be stored separately from this guide.
- Results must be documented from the cluster output actually captured during execution; anticipated output is not proof of a completed test.

## Lab Parameters

- StatefulSet resource: `web`.
- Governing Headless Service: `web-svc`.
- Namespace: `default`.
- Pod selector and template label: `app: nginx-stateful`.
- Container image: `nginx:1.27`.
- Starting replica count: `3`.
- Volume claim template: `web-data`.
- Requested capacity per claim: `100Mi`.
- Access mode: `ReadWriteOnce`.
- Container data directory: `/usr/share/nginx/html`.
- Pod management setting: `OrderedReady` unless explicitly changed.
- PVC retention setting observed in the StatefulSet description: `Retain` when scaled down and when deleted.
- Cluster DNS suffix used in the lab: `cluster.local`.
- DNS testing pod: `dns-test`, running `busybox:1.36`.

## Task 1 | Observe Replacement Behavior in a Deployment

- Create an Nginx Deployment with three replicas and inspect the generated pod names.
- Remove one Deployment-managed pod and watch the controller create a replacement.
- Compare the deleted instance's name with the replacement's name.
- Note that the new pod is another interchangeable replica, not a continuation with the same pod identity.
- Remove the demonstration Deployment before creating the StatefulSet resources.
- **What the comparison demonstrates**
  - Generated names are convenient when any replica can serve the same role.
  - A clustered stateful application may need each member to retain a predictable identity for peer configuration, discovery, or association with its data.
  - StatefulSet ordinals provide a stable naming convention for that purpose.
- **Verification commands**
  - `kubectl get deployments`
  - `kubectl get pods -l app=nginx-deployment`
  - `kubectl delete pod <deployment-pod-name>`
  - `kubectl get pods -l app=nginx-deployment -w`
  - `kubectl delete deployment nginx-deployment`

## Task 2 | Establish Pod-Level Service Discovery

- Create a Service named `web-svc` with `clusterIP: None`.
- Configure its selector to match `app: nginx-stateful`, the label applied to the StatefulSet pods.
- Expose the Nginx port through the Service.
- Set the StatefulSet's `serviceName` field to `web-svc` so that it uses this governing Service for network identity.
- A Headless Service does not allocate a virtual ClusterIP for load balancing; DNS can publish the selected pod endpoints individually.
- **Expected inspection result**
  - The Service's `CLUSTER-IP` field should show `None`.
  - Its endpoints should list the addresses of the matching ready pods once the StatefulSet is running.
- **Verification commands**
  - `kubectl get svc web-svc`
  - `kubectl describe svc web-svc`
  - `kubectl get endpoints web-svc`

## Task 3 | Run the StatefulSet and Allocate Per-Replica Storage

- Define a StatefulSet named `web` with three Nginx replicas.
- Set `serviceName: web-svc` and use the same pod label selected by the Headless Service.
- Add a `volumeClaimTemplates` entry named `web-data`.
- Request `100Mi` with `ReadWriteOnce` access for each replica.
- Mount the claim at `/usr/share/nginx/html`, the directory used later for the persistence test.
- With the default `OrderedReady` policy, Kubernetes creates the lower ordinal first and waits for it to become Ready before proceeding to the next ordinal.
- **Pod-to-claim association**
  - `web-0` uses `web-data-web-0`.
  - `web-1` uses `web-data-web-1`.
  - `web-2` uses `web-data-web-2`.
- **Expected inspection result**
  - Three StatefulSet pods should reach Ready status.
  - Three separate claims should appear and become `Bound` when storage provisioning succeeds.
  - The claim naming pattern is `<claim-template>-<statefulset-name>-<ordinal>`.
- **Verification commands**
  - `kubectl get statefulset web`
  - `kubectl describe statefulset web`
  - `kubectl get pods -l app=nginx-stateful -o wide`
  - `kubectl get pvc`
  - `kubectl get pv`

## Task 4 | Check Stable DNS Names

- Start a temporary BusyBox pod named `dns-test` inside the `default` namespace.
- Use `nslookup` from that pod to query each StatefulSet member through the governing Service.
- The lab's fully qualified names are:
  - `web-0.web-svc.default.svc.cluster.local`.
  - `web-1.web-svc.default.svc.cluster.local`.
  - `web-2.web-svc.default.svc.cluster.local`.
- Compare each returned address with the matching pod address shown by `kubectl get pods -o wide`.
- The pod DNS name is associated with the StatefulSet ordinal and governing Service; the pod IP itself is not guaranteed to remain unchanged after recreation.
- **Expected verification**
  - Each lookup should return the IP of the corresponding pod when the pod is ready and DNS is healthy.
  - A failed lookup should trigger checks of CoreDNS health, DNS Service endpoints, the Service selector, the StatefulSet `serviceName`, and pod readiness.
- **Verification commands**
  - `kubectl get pods -n kube-system -o wide`
  - `kubectl get svc kube-dns -n kube-system`
  - `kubectl get endpoints kube-dns -n kube-system`
  - `kubectl exec dns-test -- nslookup web-0.web-svc.default.svc.cluster.local`
  - `kubectl exec dns-test -- nslookup web-1.web-svc.default.svc.cluster.local`
  - `kubectl exec dns-test -- nslookup web-2.web-svc.default.svc.cluster.local`
  - `kubectl get pods -l app=nginx-stateful -o wide`
- **Cluster-specific diagnostic note**
  - The initial diagnostic capture for this lab showed a `kube-dns` Service at `10.96.0.10`, but its endpoints were empty and no CoreDNS Deployment or CoreDNS pods were present in `kube-system`.
  - BusyBox consequently could not contact a functioning cluster DNS backend at that point.
  - The StatefulSet itself was healthy, and `web-svc` listed the three pod endpoints; this isolated the initial lookup failure to the cluster DNS layer rather than the StatefulSet selector.
  - Record successful lookup output only after CoreDNS has been restored and the DNS test has been rerun.

## Task 5 | Demonstrate Storage Survives Pod Replacement

- Write a distinct marker file into each replica's mounted Nginx document directory.
- Use the following content for the three members:
  - `web-0`: `Data from web-0`.
  - `web-1`: `Data from web-1`.
  - `web-2`: `Data from web-2`.
- Read each file before deleting a pod to establish the original values.
- Remove `web-0` and wait until the StatefulSet controller has recreated it and the new instance is Ready.
- Read `/usr/share/nginx/html/index.html` from the replacement `web-0`.
- Inspect `web-data-web-0` to confirm that the original claim remains associated with the replica.
- **Expected verification**
  - The replacement should again be named `web-0`.
  - Its pod UID should differ from the removed pod's UID, showing that a new pod object was created.
  - The file should still contain `Data from web-0` because the replacement mounted the same PVC.
  - This demonstrates pod replacement with persistent-volume reuse, not a backup or disaster-recovery strategy.
- **Verification commands**
  - `kubectl exec web-0 -- cat /usr/share/nginx/html/index.html`
  - `kubectl get pvc web-data-web-0`
  - `kubectl delete pod web-0`
  - `kubectl wait --for=condition=Ready pod/web-0 --timeout=180s`
  - `kubectl exec web-0 -- cat /usr/share/nginx/html/index.html`

## Task 6 | Inspect Replica Ordering and Claim Retention

- Increase the StatefulSet from three replicas to four and wait for `web-3` to become Ready.
- Increase the desired count from four to five and wait for `web-4` to become Ready.
- Inspect the five pod names and the five corresponding claims.
- Reduce the replica count from five to three.
- Under the default ordered policy, the highest ordinal is removed first: `web-4`, followed by `web-3`.
- Inspect PVCs after both pods have terminated.
- **Replica-to-claim inventory**
  - `web-0` uses `web-data-web-0`.
  - `web-1` uses `web-data-web-1`.
  - `web-2` uses `web-data-web-2`.
  - `web-3` uses `web-data-web-3`.
  - `web-4` uses `web-data-web-4`.
- **Expected verification**
  - Five pod instances should exist at the peak replica count.
  - After reducing the count, only `web-0`, `web-1`, and `web-2` should remain.
  - The five PVCs should remain `Bound` when the StatefulSet uses the default `Retain` policy for scaled-down claims.
  - Claims for removed ordinals can be mounted again if those ordinals are recreated later.
- **Verification commands**
  - `kubectl scale statefulset web --replicas=4`
  - `kubectl scale statefulset web --replicas=5`
  - `kubectl get pods -l app=nginx-stateful -o wide`
  - `kubectl get pvc`
  - `kubectl scale statefulset web --replicas=3`
  - `kubectl get statefulset web`
  - `kubectl get pvc`
- **Retention qualification**
  - PVC retention can be changed through `persistentVolumeClaimRetentionPolicy`.
  - Check the StatefulSet configuration instead of assuming the default policy is still in effect.

## Task 7 | Remove Lab Resources Safely

- Delete the `web` StatefulSet after the required evidence has been captured.
- Delete the `web-svc` Headless Service.
- Inspect the PVCs before removing them; deleting a workload controller does not, by default, remove retained claims.
- Remove the five `web-data-web-*` claims manually when their contents are no longer required.
- Remove the temporary `dns-test` pod.
- **Storage warning**
  - The PersistentVolume reclaim policy determines what happens to backing storage after a claim is deleted.
  - The initial cluster inspection showed dynamically provisioned `standard` volumes using a `Delete` reclaim policy; deleting their PVCs may therefore remove the backing storage.
  - Confirm that no data needs to be retained before deleting the claims.
- **Verification commands**
  - `kubectl delete statefulset web`
  - `kubectl delete service web-svc`
  - `kubectl get pvc`
  - `kubectl delete pvc web-data-web-0 web-data-web-1 web-data-web-2 web-data-web-3 web-data-web-4`
  - `kubectl delete pod dns-test`



## Further Reading

- [Kubernetes documentation: StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Kubernetes documentation: Services and Headless Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Kubernetes documentation: Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
