# Oxia Helm Charts

Official Helm charts for deploying [Oxia](https://github.com/oxia-db/oxia).

## Prerequisites

- Chart version 0.0.4+ requires Oxia >= 0.16.1
- For older Oxia versions, use chart version 0.0.3

## Quick Start

```bash
helm repo add oxia https://oxia-db.github.io/helm-charts/
helm repo update
helm install my-oxia oxia/oxia-cluster
```

## Configuration

See [`values.yaml`](charts/oxia-cluster/values.yaml) for all available options.

With Oxia `v0.16.3+`, the chart advertises the public bootstrap service address by default in shard assignments:

```text
<release-name>.<namespace>.svc.cluster.local:<public-port>
```

To append more client-facing authorities, set `allowExtraAuthorities`:

```yaml
allowExtraAuthorities:
  - oxia.example.com:443
```

Use this when clients reach Oxia through external DNS names or load balancers in addition to the bootstrap service address.

## Monitoring

Grafana dashboards are available in the [oxia repository](https://github.com/oxia-db/oxia/tree/main/deploy/dashboards).

## License

Apache License 2.0
