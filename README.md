<div align="center">

# 🚀 Terraform GCP Data Processing Infrastructure

[![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/GCP-Cloud%20Platform-4285F4?logo=google-cloud&logoColor=white)](https://cloud.google.com/)

**A production-ready Infrastructure-as-Code (IaC) solution for deploying a complete data processing stack on Google Cloud Platform**

[Features](#-features) • [Quick Start](#-quick-start) • [Architecture](#-architecture) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 📖 Table of Contents

- [Problem Statement](#-problem statement)
- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Technical Challenges](#-technical-challenges--solutions)
- [Cost Estimation](#-cost-estimation)


---

## 🎯 Problem Statement

Manual infrastructure provisioning on GCP presents several critical challenges:

| Challenge | Impact |
|-----------|--------|
| **Inconsistency** | Configuration drift across environments leads to unpredictable behavior |
| **Time-Consuming** | Manual setup of VPC networking, Dataproc, and Cloud SQL takes hours |
| **Error-Prone** | Complex networking configurations are easily misconfigured |
| **Security Gaps** | Public IPs and improper firewall rules expose resources to threats |
| **No Repeatability** | Difficult to replicate infrastructure across dev/staging/prod |
| **Lack of Version Control** | Infrastructure changes aren't tracked or reviewable |

## ✨ Features

This project provides:

<table>
<tr>
<td width="33%">

### 🤖 Automation
Deploy entire infrastructure in **10-15 minutes** with a single command

</td>
<td width="33%">

### 🔒 Security First
Private IPs only, proper VPC peering and firewall rules

</td>
<td width="33%">

### 📦 Modular
Reusable modules for VPC, Dataproc, and Cloud SQL

</td>
</tr>
<tr>
<td>

### ♻️ Repeatable
Identical configuration across all environments

</td>
<td>

### 📝 Version Control
Track all infrastructure changes in Git

</td>
<td>

### 🏭 Production Ready
Service accounts, IAM roles, proper dependencies

</td>
</tr>
</table>

## 🏗 Architecture

<img width="4384" height="3223" alt="image" src="https://github.com/user-attachments/assets/2af5ea2e-feca-457c-841a-f6aaa3f0f8b5" />




### Components

| Component | Description | Configuration |
|-----------|-------------|---------------|
| **🌐 VPC Network** | Custom network with private Google API access | CIDR: `10.0.0.0/16` |
| **⚡ Dataproc Cluster** | Managed Spark/Hadoop cluster for big data | 1 Master + 2 Workers |
| **🗄️ Cloud SQL** | Private MySQL 8.0 instance | `db-n1-standard-1` |
| **🔐 Security** | Private IPs, VPC peering, internal firewall | IAM + Service Accounts |
| **💾 GCS Bucket** | Staging bucket for Dataproc jobs | Auto-created |


## 📋 Prerequisites

### Software Requirements

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (gcloud CLI)
- Git

### GCP Requirements

- GCP Project with **billing enabled**
- Appropriate IAM permissions (Project Editor or Owner)
- Required GCP APIs (will be enabled automatically):

```bash
# Enable required APIs
gcloud services enable compute.googleapis.com \
  sqladmin.googleapis.com \
  dataproc.googleapis.com \
  servicenetworking.googleapis.com \
  cloudresourcemanager.googleapis.com
```

## 🚀 Quick Start

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/yourusername/terraform-gcp-infrastructure.git
cd terraform-gcp-infrastructure
```

### 2️⃣ Configure GCP Authentication

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 3️⃣ Configure Variables

Copy the example file and edit with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"
zone       = "us-central1-a"
prefix     = "data-platform"

# Optional: Override defaults
# vpc_cidr_range        = "10.0.0.0/16"
# dataproc_worker_count = 3
# sql_tier              = "db-n1-standard-2"
```

### 4️⃣ Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Deploy infrastructure
terraform apply
```

> ⏱️ **Deployment Time**: Approximately 10-15 minutes

### 5️⃣ Access Your Resources

After deployment, Terraform will output connection details:

```bash
terraform output
```

## 📁 Project Structure

```
📦 terraform-gcp-infrastructure
├── 📂 modules/
│   ├── 📂 vpc/
│   │   ├── main.tf           # VPC network configuration
│   │   ├── outputs.tf        # Network outputs
│   │   └── variables.tf      # VPC variables
│   ├── 📂 dataproc/
│   │   ├── main.tf           # Dataproc cluster configuration
│   │   ├── outputs.tf        # Cluster outputs
│   │   └── variables.tf      # Dataproc variables
│   └── 📂 cloudsql/
│       ├── main.tf           # Cloud SQL configuration
│       ├── outputs.tf        # Database outputs
│       └── variables.tf      # SQL variables
├── main.tf                   # Root module (orchestrates all modules)
├── variables.tf              # Root variables
├── outputs.tf                # Root outputs
├── terraform.tfvars.example  # Example variable configuration
├── .gitignore                # Git ignore rules
├── LICENSE                   # License file
└── README.md                 # This file
```


## 🔐 Security

### Security Features

- ✅ **Private IP Only**: All resources use internal IPs, no public exposure
- ✅ **VPC Peering**: Secure private connection between Cloud SQL and VPC
- ✅ **IAM Best Practices**: Dedicated service accounts with minimal permissions
- ✅ **Firewall Rules**: Internal-only traffic allowed
- ✅ **Private Google Access**: Access GCP APIs without public IPs
- ✅ **Automated Backups**: Cloud SQL automated backups enabled


## 🔧 Technical Challenges & Solutions

<details>
<summary><b>🔴 Challenge 1: Private Cloud SQL Connectivity</b></summary>

**Problem**: Cloud SQL instances with private IPs require complex VPC peering through Service Networking API.

**Solution**: 
- Automated VPC peering using `google_compute_global_address`
- Reserve IP range for Private Service Access
- Establish peering with `google_service_networking_connection`
- Proper dependency chain ensures VPC is ready before SQL creation

```hcl
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
```
</details>

<details>
<summary><b>🔴 Challenge 2: Dataproc IAM Configuration</b></summary>

**Problem**: Dataproc clusters need specific service accounts and IAM permissions to access GCS staging buckets.

**Solution**:
- Created dedicated service account with `dataproc.worker` role
- Granted `storage.admin` access to staging bucket
- Configured proper `service_account_scopes` for cluster nodes

```hcl
resource "google_service_account" "dataproc_sa" {
  account_id   = "dataproc-service-account"
  display_name = "Dataproc Service Account"
}

resource "google_project_iam_member" "dataproc_worker" {
  project = var.project_id
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.dataproc_sa.email}"
}
```
</details>

<details>
<summary><b>🔴 Challenge 3: Internal-Only Networking</b></summary>

**Problem**: Resources needed to communicate privately without public IP exposure.

**Solution**:
- Enabled `private_ip_google_access` on subnet
- Set `internal_ip_only = true` on Dataproc cluster
- Disabled IPv4 (`ipv4_enabled = false`) on Cloud SQL
- Created firewall rules allowing internal traffic

```hcl
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/16"]
}
```
</details>

<details>
<summary><b>🔴 Challenge 4: Resource Dependencies</b></summary>

**Problem**: Resources must be created in specific order, but Terraform's parallel execution can cause failures.

**Solution**: Used explicit `depends_on` declarations:
- Cloud SQL depends on Service Networking connection
- Service Networking connection depends on VPC
- Firewall rules depend on VPC network

```hcl
resource "google_sql_database_instance" "instance" {
  name             = "sql-instance"
  database_version = "MYSQL_8_0"
  
  depends_on = [google_service_networking_connection.private_vpc_connection]
  
  settings {
    tier = "db-n1-standard-1"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.id
    }
  }
}
```
</details>

<details>
<summary><b>🔴 Challenge 5: Module Reusability</b></summary>

**Problem**: Need to deploy similar infrastructure across multiple environments without code duplication.

**Solution**:
- Separated infrastructure into reusable modules (VPC, Dataproc, Cloud SQL)
- Variable-driven configuration with `terraform.tfvars`
- Naming prefix system for multi-environment support

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_id = var.project_id
  region     = var.region
  prefix     = var.prefix
}

module "dataproc" {
  source = "./modules/dataproc"
  
  project_id = var.project_id
  region     = var.region
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnetwork_name
}
```
</details>


## 💰 Cost Estimation

> 💡 **Tip**: Use preemptible workers for Dataproc to reduce costs by up to 80%

Calculate exact costs: [GCP Pricing Calculator](https://cloud.google.com/products/calculator)


## 🙏 Acknowledgments

- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Best Practices](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations)
- HashiCorp Terraform Community

---

<div align="center">

**Made with ❤️ by Mitraa More(https://github.com/yourusername)**

</div>
