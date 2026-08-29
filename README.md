# 🚀 Kafka on EKS

> Deploy Apache Kafka (Strimzi) on Amazon EKS, bootstrapped with Argo CD.

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/eks/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-231F20?style=for-the-badge&logo=apachekafka&logoColor=white)](https://kafka.apache.org/)
[![Strimzi](https://img.shields.io/badge/Strimzi-000000?style=for-the-badge&logo=apachekafka&logoColor=white)](https://strimzi.io/)
[![Argo CD](https://img.shields.io/badge/Argo%20CD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io/cd/)

---

## 📖 Overview

This repository provisions a production-style **Apache Kafka** cluster on **Amazon EKS**
using **Strimzi** as the operator, with **Argo CD** handling GitOps-based application
deployment.

The infrastructure is defined in Terraform and the Kafka workloads are managed as Argo CD
applications, so everything is declarative and reproducible.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Amazon EKS                           │
│                                                             │
│   ┌──────────────┐      ┌──────────────────────────────┐    │
│   │   Argo CD    │─────▶│   Strimzi Operator          │    │
│   │  (GitOps)    │      │   (kafka.strimzi.io CRDs)   │    │
│   └──────────────┘      └──────────────┬───────────────┘    │
│                                        │                    │
│                              ┌─────────▼─────────┐          │
│                              │   Kafka Cluster   │          │
│                              │  (KRaft mode)     │          │
│                              └───────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

- **Terraform** provisions the EKS cluster, node groups, and Argo CD.
- **Argo CD** watches the `manifests/` directory and syncs the Kafka resources.
- **Strimzi** reconciles the `Kafka` / `KafkaNodePool` custom resources into running brokers.

---

## 📁 Repository Layout

```
eks-ingress-kafka/
├── infra/
│   ├── aws/                  # Terraform for the EKS cluster
│   │   ├── eks.cluster.tf    # EKS module + Argo CD Application
│   │   └── output.tf
│   └── local/                # Local (kind) bootstrap script
│       └── init.sh
├── manifests/                # Kafka manifests synced by Argo CD
│   ├── kafka.cluster.yml     # Kafka CR (KRaft)
│   ├── kafka.broker.yml      # KafkaNodePool (broker)
│   ├── kafka.controller.yml  # KafkaNodePool (controller)
│   ├── kafka.namespace.yaml  # kafka namespace
│   └── strimzi-crds.yaml     # Strimzi CRDs
├── postmortem/               # Incident write-ups
└── .gitignore
```

---

## ✨ Features

- ✅ **EKS cluster** provisioned with a reusable Terraform module
- ✅ **Argo CD** installed and bootstrapped with a `kafka` Application
- ✅ **GitOps** — Kafka manifests synced automatically from `manifests/`
- ✅ **Strimzi operator** with `kafka.strimzi.io` CRDs
- ✅ **KRaft mode** Kafka (no ZooKeeper)
- ✅ **CreateNamespace** sync option — namespace created on demand

---

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/) (for Argo CD)

### 1️⃣ Provision the EKS cluster

```bash
cd infra/aws
terraform init
terraform plan
terraform apply -auto-approve
```

### 2️⃣ Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name kafka-cluster
```

### 3️⃣ Install the Strimzi operator

```bash
kubectl apply -f manifests/strimzi-crds.yaml
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
```

### 4️⃣ Deploy Kafka via Argo CD

The `kafka` Argo CD Application is created by Terraform and syncs the manifests in
`manifests/` automatically.

```bash
kubectl get applications -n argocd
kubectl get kafka -n kafka
```

---

## 🧪 Local Development (kind)

For a quick local cluster, use the bootstrap script:

```bash
./infra/local/init.sh
```

This creates a `kind` cluster, the `kafka` namespace, and installs Strimzi.

---

## 🛠️ Useful Commands

```bash
# Argo CD UI
kubectl -n argocd port-forward svc/argocd-server 8080:443

# Get the admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 --decode; echo

# Check Kafka status
kubectl get kafka,kafkanodepool -n kafka
```

---

## 📄 License

This project is for educational / POC purposes.
