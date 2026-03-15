# Oxia Helm Charts

Official Helm charts for deploying [Oxia](https://github.com/oxia-db/oxia).

## Quick Start

```bash
helm repo add oxia https://oxia-db.github.io/helm-charts/
helm repo update
helm install my-oxia oxia/oxia-cluster
```

## Configuration

See [`values.yaml`](charts/oxia-cluster/values.yaml) for all available options.

## Monitoring

Grafana dashboards are available in the [oxia repository](https://github.com/oxia-db/oxia/tree/main/deploy/dashboards).

## License

Apache License 2.0
