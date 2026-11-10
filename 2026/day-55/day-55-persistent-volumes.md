# Day 55 – Kubernetes Persistent Storage

## Overview

- Examined how Kubernetes storage behaves when a Pod is removed and recreated.
- Compared temporary Pod storage with storage requested through PersistentVolumeClaims (PVCs).
- Created a manually managed PersistentVolume (PV) and connected it to a PVC.
- Inspected the cluster's StorageClass and investigated why dynamic provisioning initially remained pending.
- Kept the YAML manifests and practical evidence alongside this README.

## Task 1: Examine temporary volume behaviour

- Created a Pod with an `emptyDir` volume mounted at `/data`.
- Wrote a timestamped entry to `/data/message.txt`.
- Deleted the Pod and created another Pod from the same manifest.
- Checked the file in the replacement Pod.
- **Observation:** The new Pod received a fresh `emptyDir` volume, so the earlier message was no longer present.
- **Important detail:** An `emptyDir` remains available during a container restart as long as the same Pod continues to exist. Its contents are removed when that Pod is removed from the node.

## Task 2: Create a static PersistentVolume

- Defined a PV manifest with these settings:
  - Capacity: `1Gi`.
  - Access mode: `ReadWriteOnce`.
  - Reclaim policy: `Retain`.
  - Volume type: `hostPath`.
  - Node directory: `/tmp/k8s-pv-data`.
  - StorageClass name: empty string (`""`).
- Applied the manifest and inspected the PV with `kubectl get pv` and `kubectl describe pv static-pv`.
- **Observation:** Before a claim was connected, the PV was in the `Available` state.
- **Important details:**
  - `ReadWriteOnce` allows read-write mounting from one node; it does not necessarily limit access to one Pod on that node.
  - `Retain` leaves the underlying storage for manual handling after the PVC is deleted.
  - `hostPath` refers to a directory on a particular Kubernetes node. It is suitable for this controlled learning exercise, not a general production storage solution.
  - The cluster used for this exercise has one `kind-control-plane` node, which avoids moving the test workload between nodes.

## Task 3: Create and bind a PersistentVolumeClaim

- Created a PVC requesting:
  - Storage: `500Mi`.
  - Access mode: `ReadWriteOnce`.
  - StorageClass name: empty string (`""`).
- Kept the PVC's empty StorageClass name consistent with the manually created PV.
- Applied the PVC and checked both the claim and volume.
- **Observation:** The PVC became `Bound` and its `VOLUME` field identified `static-pv`.
- **Important detail:** The PV continues to report its full `1Gi` capacity; the PVC's `500Mi` request does not resize the PV.

## Task 4: Preserve data when a Pod is replaced

- Created a Pod that mounted `static-pvc` at `/data`.
- Wrote an initial entry to `/data/message.txt`.
- Deleted the Pod without deleting its PVC or PV.
- Created a replacement Pod using the same PVC.
- Read the original entry and appended another entry from the replacement Pod.
- **Observation:** The file retained the earlier entry and accepted the new one.
- **Conclusion:** The data is stored on the persistent volume rather than in the lifetime of the original Pod.
- **Node consideration:** Since this exercise uses `hostPath`, the replacement Pod must access the same node-local directory to see the same data.

## Task 5: Inspect the StorageClass

- Used `kubectl get storageclass` to list the available classes.
- Used `kubectl describe storageclass standard` to inspect the default class.
- **Observed cluster configuration:**
  - Kubernetes context: `kind-kind`.
  - Kubernetes node: `kind-control-plane`.
  - Default StorageClass: `standard`.
  - Provisioner name: `rancher.io/local-path`.
  - Reclaim policy: `Delete`.
  - Volume binding mode: `WaitForFirstConsumer`.
  - Volume expansion: disabled (`false`).
- **Important detail:** `WaitForFirstConsumer` delays provisioning and binding until a Pod using the PVC is considered for scheduling. A claim can remain `Pending` before a consumer Pod is created.

## Task 6: Investigate dynamic provisioning

- Created `dynamic-pvc` requesting `500Mi` from the `standard` StorageClass.
- Created `dynamic-writer` to consume that claim.
- The PVC referenced the StorageClass rather than a manually named PV.
- **Initial diagnostic findings:**
  - `dynamic-pvc` remained `Pending`.
  - `dynamic-writer` remained `Pending` and had no assigned node.
  - PVC events reported that Kubernetes was waiting for the external provisioner `rancher.io/local-path`.
  - The diagnostic found no matching local-path provisioner Pod or Deployment in the cluster at that time.
  - The StorageClass definition existed, but the controller required to create the volume was not present in the inspected workloads.
- **Required follow-up:**
  - Install and run a provisioner that registers as `rancher.io/local-path`.
  - Confirm that the provisioner Pod is healthy.
  - Confirm that `dynamic-pvc` changes to `Bound`.
  - Confirm that a dynamically created PV appears in `kubectl get pv`.
  - Confirm that `dynamic-writer` reaches `Running`.
  - Write data, recreate the Pod while keeping the same PVC, and verify that the earlier data remains accessible.
- **Verification commands:**

  ```bash
  kubectl get pods -n local-path-storage
  kubectl get storageclass
  kubectl get pvc dynamic-pvc
  kubectl get pv
  kubectl get pod dynamic-writer -o wide
  kubectl exec dynamic-writer -- cat /data/message.txt
  ```

- **Status note:** The diagnostic output available when this README was prepared was captured before the provisioner installation was verified. Therefore, dynamic provisioning and its persistence test are recorded as requiring post-installation confirmation rather than being claimed as completed.

## Task 7: Inspect reclaim behaviour and clean up

- Removed the Pods consuming the PVCs before deleting the claims.
- Deleted the static PVC and inspected the associated PV.
- **Expected static-volume result:** The PV with `Retain` remains in the `Released` state after its PVC is deleted.
- Removed the retained PV object manually after inspecting the retained storage.
- **Expected dynamic-volume result:** The observed `standard` StorageClass specifies `Delete`. After successful dynamic provisioning, deleting its PVC should cause the provisioner to remove the dynamically created PV and its backing storage, provided the deletion operation completes successfully.
- **Important details:**
  - Deleting a PV object with `Retain` does not itself erase the files in the `hostPath` directory.
  - Removing the underlying node directory is a separate action and should only be done deliberately when its contents are no longer required.
  - The diagnostic also showed `test-pv` and `test-pvc`; these were separate pre-existing resources and should not be removed as part of this exercise unless they are confirmed to be disposable.

## Key takeaways

- **`emptyDir`:**
  - Created for a Pod.
  - Data is available to containers in that Pod.
  - Data is removed when the Pod is removed.
  - No PVC is involved.
- **Static PV:**
  - Created manually from a PV manifest.
  - Can preserve data beyond the lifetime of an individual Pod.
  - The example used `hostPath`, `ReadWriteOnce`, and `Retain`.
  - Its PV remains `Released` after claim deletion when the reclaim policy is `Retain`.
- **PVC:**
  - Represents a workload's request for storage.
  - Binds to a suitable PV.
  - A Pod uses the PVC instead of directly selecting the PV.
- **StorageClass and dynamic provisioning:**
  - A StorageClass identifies a provisioner and storage behaviour.
  - A working provisioner is required to create dynamic volumes.
  - The cluster's `standard` class used `rancher.io/local-path`, `Delete`, and `WaitForFirstConsumer`.
- **Lifecycle distinction:**
  - Deleting a Pod does not automatically delete its PVC or PV.
  - Deleting a PVC invokes the PV's reclaim policy.
  - The storage backend and provisioner must support the configured reclamation operation.

## Conclusion

- Demonstrated the lifecycle difference between `emptyDir` and persistent storage.
- Created and bound a static PV/PVC pair.
- Used the static claim from a replacement Pod to verify data continuity.
- Identified the cluster's default StorageClass and its configuration.
- Diagnosed the missing local-path provisioner as the blocker in the initial dynamic-provisioning attempt.
- Dynamic provisioning should be marked complete only after the provisioner, generated PV, bound PVC, running Pod, data persistence test, and reclaim behaviour have all been verified in the cluster.
