# Oxia Helm Charts

Official Helm charts for deploying [Oxia](https://github.com/oxia-db/oxia).

## Prerequisites

- Chart version 0.0.4+ requires Oxia >= 0.16.1
- For older Oxia versions, use chart version 0.0.3

## Oxia version

The chart deploys the Oxia version in its `appVersion` (0.18.0 for chart 0.0.9). To run another version, set `image.tag`:

```bash
helm install my-oxia oxia/oxia-cluster --set image.tag=0.17.1
```

Chart versions up to 0.0.8 default to `image.tag: latest` with `pullPolicy: Always`, so a restarted pod pulls whatever `latest` is at that time, which is now 0.18.0. Pin `image.tag` to the version you run, and upgrade on purpose.

Before upgrading Oxia, read the upgrade and downgrade notes of the [release](https://github.com/oxia-db/oxia/releases).

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
