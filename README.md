# Oxia Helm Charts

This repository contains the official Helm charts for deploying [Oxia](https://github.com/oxia-db/oxia), a distributed, embedded, and highly available database.

## Prerequisites

Before you begin, ensure you have the following installed:

* **Kubernetes cluster** 
* **Helm**

## Quick Start

Follow these steps to add the Oxia Helm repository and install a release.

1.  **Add the Helm repository:**

    ```bash
    helm repo add oxia https://oxia-db.github.io/helm-charts/
    helm repo update
    ```

2.  **Install the chart:**

    You can deploy Oxia with a simple `helm install` command. This will create a release named `my-release` in your current namespace.

    ```bash
    helm install my-release oxia/oxia-cluster
    ```

## Configuration

You can customize your deployment by using the `--set` flag or by providing a custom `values.yaml` file.

To see all available configuration options, refer to the `values.yaml` file in the chart's repository.

---

### Example: Customizing the Release

To install a specific version and provide custom values, use the `--version` flag and the `-f` flag.

```bash
helm install my-release oxia-db/oxia --version 0.1.0 -f values.yaml