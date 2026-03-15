# Oxia Helm Charts

This repository contains the official Helm charts for deploying [Oxia](https://github.com/oxia-db/oxia), a scalable metadata store designed for large-scale distributed systems.

## Prerequisites

* Kubernetes 1.23+
* Helm 3.x

## Quick Start

1. **Add the Helm repository:**

    ```bash
    helm repo add oxia https://oxia-db.github.io/helm-charts/
    helm repo update
    ```

2. **Install the chart:**

    ```bash
    helm install my-oxia oxia/oxia-cluster
    ```

3. **Verify the deployment:**

    ```bash
    kubectl get pods -l app.kubernetes.io/instance=my-oxia
    ```

## Configuration

### Cluster Topology

| Parameter | Description | Default |
|-----------|-------------|---------|
| `initialShardCount` | Number of shards | `3` |
| `replicationFactor` | Replication factor per shard | `3` |
| `server.replicas` | Number of server pods | `3` |

For multiple namespaces:

```yaml
namespaces:
  - name: default
    initialShardCount: 3
    replicationFactor: 3
  - name: my-namespace
    initialShardCount: 1
    replicationFactor: 3
```

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `server.cpu` | Server CPU request/limit | `1` |
| `server.memory` | Server memory request/limit | `1Gi` |
| `server.storage` | PVC size for data | `8Gi` |
| `server.storageClassName` | Storage class for PVC | (default) |
| `coordinator.cpu` | Coordinator CPU request/limit | `100m` |
| `coordinator.memory` | Coordinator memory request/limit | `128Mi` |

### Image

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image | `oxia/oxia` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Pull policy | `Always` |
| `image.pullSecrets` | Image pull secret name | (none) |

### Server Configuration

Server and coordinator settings are passed directly as YAML config under `server.config` and `coordinator.config`. See [`values.yaml`](charts/oxia-cluster/values.yaml) for the full structure, including:

- Bind addresses for public, internal, and metrics ports
- TLS configuration for public and replication endpoints
- Storage settings (WAL directory, sync mode, retention, DB cache size)
- Observability (metrics endpoint, log level)

### Monitoring

| Parameter | Description | Default |
|-----------|-------------|---------|
| `monitoringEnabled` | Enable Prometheus annotations and ServiceMonitor | `false` |
| `pprofEnabled` | Enable pprof profiling endpoint | `false` |

When `monitoringEnabled` is set to `true`, a `ServiceMonitor` resource is created with two endpoints:
- `ds-metrics` — dataserver metrics
- `co-metrics` — coordinator metrics

### Grafana Dashboards

Pre-built Grafana dashboards are available in the [oxia repository](https://github.com/oxia-db/oxia/tree/main/deploy/dashboards):

- **Cluster Overview** — node health, throughput, write latency, disk usage
- **Coordinator** — leader elections, metadata operations, node status
- **Nodes** — per-node operations, WAL, database, and Pebble storage metrics
- **Shards** — per-shard read/write ops, latency, WAL, and storage
- **gRPC** — server and client request rates, message throughput
- **Go Processes** — memory, GC, goroutines, file descriptors

To use with kube-prometheus-stack, apply the provided values overlay:

```bash
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -f https://raw.githubusercontent.com/oxia-db/oxia/main/deploy/dashboards/values-kube-prometheus-stack.yaml
```

## Architecture

Each server pod runs two containers as sidecars:
- **dataserver** — handles client read/write operations and data storage
- **coordinator** — manages cluster topology, shard assignments, and leader election

### ConfigMaps

| ConfigMap | Description |
|-----------|-------------|
| `{release}-coordinator` | Cluster topology (namespaces, server addresses) |
| `{release}-daemon` | Daemon configs (`coordinator.yaml` + `dataserver.yaml`) |
| `{release}-status` | Cluster status (created at runtime by coordinator) |

### Services

| Service | Description |
|---------|-------------|
| `{release}-svc` | Headless service for StatefulSet DNS |
| `{release}` | ClusterIP service for client access |

## Development

### Running Tests

The CI pipeline automatically runs on PRs:

```bash
# Lint the chart
helm lint charts/oxia-cluster

# Template rendering
helm template my-oxia charts/oxia-cluster

# Full integration test (requires kind)
kind create cluster
helm install my-oxia charts/oxia-cluster \
  --set server.replicas=3 \
  --set initialShardCount=1 \
  --set replicationFactor=3 \
  --wait --timeout 5m
helm test my-oxia
```

## License

Licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.
