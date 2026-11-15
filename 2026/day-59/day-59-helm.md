# Day 59 - Helm: Kubernetes Package Management

## Overview
- Explored Helm for templating, packaging, and deploying Kubernetes resources.
- Managed application configurations through chart values.
- Practiced release versioning, upgrades, and rollbacks.
- Developed and deployed a custom Helm chart.

## Objectives
- Understand Helm architecture and chart lifecycle.
- Deploy NGINX using Bitnami charts.
- Configure workloads through YAML values.
- Manage release revisions and recovery.
- Build reusable Kubernetes deployment templates.

## Core Concepts
- **Chart:** Packages Kubernetes manifest templates and default configurations.
- **Release:** Represents an installed chart instance.
- **Repository:** Stores and distributes Helm charts.
- **Values:** Supplies configurable parameters to templates.
- **Revision:** Tracks successive release modifications.

## Task 1 - Helm Installation
- Installed Helm CLI on Ubuntu.
- Verified Helm version and environment variables.
- Checked Kubernetes cluster connectivity.
- Inspected Helm configuration and repository paths.

## Task 2 - Chart Repository Management
- Added the Bitnami chart repository.
- Refreshed repository indexes.
- Searched available NGINX charts.
- Examined chart versions and application metadata.
- Counted distinct available chart packages.

## Task 3 - NGINX Deployment
- Installed NGINX through the Bitnami chart.
- Examined generated Deployments, Pods, and Services.
- Inspected release metadata and rendered manifests.
- Verified workload readiness and Service exposure.

**Implementation Logic:**
- Helm renders Kubernetes templates using chart values.
- Generated manifests are submitted to the Kubernetes API.
- Kubernetes controllers reconcile the desired workload state.

## Task 4 - Helm Values and Configuration

- Inspected default chart configurations.
- Overrode replica count and Service type.
- Created `custom-values.yaml`.
- Configured container resource requests and limits.
- Installed an additional release using external values.
- Verified effective configuration and live resources.

**YAML Configuration Logic:**

- `replicaCount: 3` – Defines the desired number of application replicas.
- `service.type: NodePort` – Exposes the application through a node-level port.
- `resources.requests` – Specifies CPU and memory required for scheduling.
- `resources.limits` – Defines container resource consumption boundaries.

## Task 5 - Release Upgrade and Rollback

- Updated the NGINX replica configuration to five.
- Inspected Helm release revision history.
- Rolled back to the initial revision.
- Verified restored deployment configuration.

**Release Lifecycle Logic:**
- Upgrade generates a new release revision.
- History maintains previous configuration records.
- Rollback reapplies a selected revision as a new revision.
- Kubernetes controllers reconcile the restored desired state.

## Task 6 - Custom Helm Chart Development

- Scaffolded a chart using `helm create`.
- Examined `Chart.yaml`, `values.yaml`, and template directories.
- Configured three initial replicas.
- Defined the NGINX container image as `nginx:1.25`.
- Explored Go template expressions and built-in objects.
- Validated chart structure using `helm lint`.
- Rendered Kubernetes manifests using `helm template`.
- Installed the custom chart.
- Upgraded the workload from three to five replicas.

**Chart File Logic:**

- `Chart.yaml` – Defines chart identity, metadata, and version.
- `values.yaml` – Stores default deployment parameters.
- `templates/deployment.yaml` – Generates a parameterized Deployment manifest.
- `templates/service.yaml` – Generates Service configuration.
- `_helpers.tpl` – Contains reusable naming and labeling templates.

**Go Template Logic:**

- `{{ .Values.replicaCount }}` – Injects the configured replica count.
- `{{ .Chart.Name }}` – Retrieves chart metadata.
- `{{ .Release.Name }}` – Retrieves the active release identifier.

## Task 7 - Cleanup and Verification

- Uninstalled all lab-created Helm releases.
- Removed associated Kubernetes workloads.
- Verified remaining release records.
- Preserved chart source files and configuration for GitHub submission.

## Troubleshooting
- Corrected YAML indentation and mapping errors.
- Resolved invalid chart directory references.
- Fixed multiline command formatting.
- Inspected template rendering and lint validation output.
- Verified configuration against generated manifests.

## Key Technical Learnings
- Helm provides declarative application packaging for Kubernetes.
- Template rendering separates configuration from resource definitions.
- Values files enable environment-specific deployments.
- Release revisions provide configuration rollback capabilities.
- Chart linting and manifest rendering improve deployment validation.
- Kubernetes controllers maintain the desired workload state.

## Verification Checklist
- [ ] Helm CLI installed and verified.
- [ ] Bitnami repository configured and indexed.
- [ ] NGINX chart successfully deployed.
- [ ] Three replicas and NodePort configuration verified.
- [ ] Resource requests and limits inspected.
- [ ] Upgrade and rollback revisions verified.
- [ ] Custom chart linting and rendering successful.
- [ ] Custom deployment scaled from three to five replicas.
- [ ] Helm releases and lab workloads cleaned up.
