# Day 54 - Kubernetes ConfigMaps and Secrets

## Lab Goal

- Keep application settings outside container images so configuration can change independently of an image build.
- Use ConfigMaps for ordinary settings and configuration files.
- Use Secrets for credentials and other confidential values.
- Compare environment-variable injection with mounted configuration files.
- Observe how an updated ConfigMap appears in a volume-mounted file.

## 1. ConfigMap from Literal Values

- Created `app-config` with three application settings:
  - `APP_ENV=production`
  - `APP_DEBUG=false`
  - `APP_PORT=8080`
- Used `--from-literal` to add each key/value pair directly to the resource.

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  --from-literal=APP_PORT=8080

kubectl describe configmap app-config
kubectl get configmap app-config -o yaml
```

- `kubectl describe` provides a readable summary of the stored keys.
- `-o yaml` displays the resource definition and its `data` section.
- ConfigMap values are ordinary, non-confidential configuration data; they are not encrypted by being stored in a ConfigMap.

## 2. ConfigMap from an Nginx File

- Created `nginx/default.conf` as the source configuration file.
- Added an exact `/health` location that responds with HTTP status `200` and the plain-text body `healthy`.
- Kept the normal `/` location so the standard Nginx welcome page remains available.

```nginx
server {
    listen 80;
    server_name _;

    location = /health {
        default_type text/plain;
        return 200 "healthy\n";
    }

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
```

- Created `nginx-config` using the file contents and assigned the ConfigMap key `default.conf`.

```bash
kubectl create configmap nginx-config \
  --from-file=default.conf=nginx/default.conf

kubectl describe configmap nginx-config
kubectl get configmap nginx-config -o yaml
```

- The key `default.conf` is used as the filename when this ConfigMap is mounted as a directory in a container.

## 3. Make ConfigMaps Available to Pods

### Environment variables

- `configmap-env-pod.yaml` defines the `app-config-env` Pod.
- Its `envFrom.configMapRef` imports every key in `app-config` as a container environment variable.
- The BusyBox process prints the three settings and exits; `Completed` is therefore an expected Pod phase.

```bash
kubectl apply --dry-run=client -f configmap-env-pod.yaml
kubectl apply -f configmap-env-pod.yaml
kubectl logs app-config-env
```

### Nginx configuration volume

- `nginx-config-pod.yaml` defines the `nginx-config-pod` Pod.
- A ConfigMap-backed volume named `nginx-config-volume` is mounted read-only at `/etc/nginx/conf.d`.
- The `default.conf` key is projected into the container at `/etc/nginx/conf.d/default.conf`.

```bash
kubectl apply --dry-run=client -f nginx-config-pod.yaml
kubectl apply -f nginx-config-pod.yaml
kubectl wait --for=condition=Ready pod/nginx-config-pod --timeout=120s

kubectl exec nginx-config-pod -- ls -l /etc/nginx/conf.d/
kubectl exec nginx-config-pod -- cat /etc/nginx/conf.d/default.conf
kubectl exec nginx-config-pod -- nginx -t
```

- To test the endpoint without relying on `curl` being installed in the Nginx image, forward the Pod's port to the EC2 host in one terminal:

```bash
kubectl port-forward pod/nginx-config-pod 8080:80
```

- From another terminal on that host, send the request:

```bash
curl -i http://127.0.0.1:8080/health
```

- The expected response is HTTP `200` with body `healthy`.
- Environment variables suit individual settings; a volume mount is more suitable for a multi-line server configuration file.

## 4. Create and Inspect a Secret

- Created the generic Secret `db-credentials` with keys `DB_USER` and `DB_PASSWORD`.
- The lab values are test credentials only. Do not reuse a real password, publish decoded output, or commit credential values to the repository.
- To avoid placing the password literally in this Markdown file or shell history, enter it interactively:

```bash
read -rsp "Enter disposable lab DB password: " DB_PASSWORD
printf '\n'
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD="$DB_PASSWORD"
unset DB_PASSWORD
```

- Inspect the Secret metadata and keys without printing the values:

```bash
kubectl describe secret db-credentials
kubectl get secret db-credentials
```

- Kubernetes represents values in the Secret resource's `.data` field using Base64. Base64 is reversible encoding, not encryption.
- A user or workload with permission to read a Secret can retrieve and decode its contents. Use restrictive RBAC and configure encryption at rest for the cluster's Secret data in etcd.
- The following command extracts and decodes the password. Run it only in the private lab terminal; do not copy its output into Git, screenshots, logs, or chat:

```bash
kubectl get secret db-credentials \
  -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode
printf '\n'
```

## 5. Provide the Secret to a Pod

- `secret-consumer-pod.yaml` defines the `secret-consumer` Pod.
- `secretKeyRef` exposes only `DB_USER` as an environment variable.
- A Secret-backed volume exposes both Secret keys as files under `/etc/db-credentials`.
- The volume mount is read-only. The container remains active so the mounted files can be inspected.

```bash
kubectl apply --dry-run=client -f secret-consumer-pod.yaml
kubectl apply -f secret-consumer-pod.yaml
kubectl wait --for=condition=Ready pod/secret-consumer --timeout=120s

kubectl exec secret-consumer -- printenv DB_USER
kubectl exec secret-consumer -- ls -l /etc/db-credentials/
kubectl exec secret-consumer -- cat /etc/db-credentials/DB_USER
```

- The projected files contain decoded plaintext values, not Base64 text.
- To verify the password file locally, use `kubectl exec secret-consumer -- cat /etc/db-credentials/DB_PASSWORD`; keep the result private and out of recorded output.
- Treat mounted Secret files and environment variables as sensitive: a process running in the container can read values made available to it.

## 6. Observe a ConfigMap Volume Update

- Created `live-config` with `message=hello`.
- `live-config-pod.yaml` defines a Pod that mounts this ConfigMap at `/etc/live-config` and reads the file every five seconds.
- The volume is mounted as a directory, not through `subPath`, so Kubernetes can refresh the projected content.

```bash
kubectl create configmap live-config --from-literal=message=hello
kubectl apply -f live-config-pod.yaml
kubectl wait --for=condition=Ready pod/live-config-reader --timeout=120s
kubectl logs -f live-config-reader
```

- In another terminal, change the ConfigMap value:

```bash
kubectl patch configmap live-config --type merge \
  -p '{"data":{"message":"world"}}'
```

- Continue watching the Pod logs and allow time for the kubelet's ConfigMap refresh to reach the mounted volume.
- The file should eventually show `world` without restarting the Pod. The refresh is asynchronous, so do not treat 30–60 seconds as a hard guarantee.
- Environment variables populated from a ConfigMap are fixed when the container starts; changing the ConfigMap does not rewrite the environment of an already-running process.
- A process must reread a refreshed mounted file (or otherwise reload its configuration) before it can use the new value.

## Useful Verification Commands

```bash
# Review configuration resources
kubectl get configmaps
kubectl get configmap app-config -o yaml
kubectl get configmap nginx-config -o yaml

# Review Secret metadata without exposing its values
kubectl get secrets
kubectl describe secret db-credentials

# Review the lab Pods
kubectl get pods -o wide
kubectl logs app-config-env

# Inspect the Nginx configuration and validate its syntax
kubectl exec nginx-config-pod -- cat /etc/nginx/conf.d/default.conf
kubectl exec nginx-config-pod -- nginx -t

# Inspect Secret consumption without printing the password
kubectl exec secret-consumer -- printenv DB_USER
kubectl exec secret-consumer -- ls -l /etc/db-credentials/

# Watch the live ConfigMap reader
kubectl logs -f live-config-reader
```

## Cleanup

- Stop any active `kubectl port-forward` session with `Ctrl+C`.
- Remove the Pods created for this exercise:

```bash
kubectl delete pod \
  app-config-env \
  nginx-config-pod \
  secret-consumer \
  live-config-reader \
  --ignore-not-found
```

- Remove the ConfigMaps and Secret:

```bash
kubectl delete configmap app-config nginx-config live-config --ignore-not-found
kubectl delete secret db-credentials --ignore-not-found
```

- Confirm that the lab resources are gone:

```bash
kubectl get pods
kubectl get configmaps
kubectl get secrets
```

## Key Takeaways

- ConfigMaps keep non-sensitive settings separate from container images.
- Secrets are intended for confidential values, but Base64 alone does not protect them.
- `envFrom` imports all ConfigMap keys; `secretKeyRef` selects an individual Secret key.
- ConfigMap and Secret volumes expose their data as files inside the container.
- Mounted ConfigMap files are refreshed eventually; applications may need to reread them.
- Environment variables do not change inside an already-running container after the source ConfigMap or Secret is updated.
- RBAC, careful workload access, and encryption at rest are important parts of Secret protection.
