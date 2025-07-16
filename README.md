# 🚀 Production-Ready Multi-Tier App Infrastructure on AWS

This project provisions a fully automated, production-grade multi-tier infrastructure on AWS using **modular Terraform**, following modern best practices for **high availability**, **cost efficiency**, **security**, and **automation**.

---

## ✅ Key Features

- **🧱 Modular Terraform Architecture**\
  Each major component (VPC, IAM, ALB, EC2 app tier, RDS, S3) is implemented as a reusable Terraform module with clearly defined input and output variables.

- **🌐 Remote State + Workspaces**\
  Remote Terraform state is stored in S3 with state locking via DynamoDB. Environments (`dev` and `prod`) are isolated using Terraform workspaces.

- **🔐 Least Privilege IAM Roles**\
  Fine-grained IAM roles are provisioned for EC2, RDS, and ALB with resource-scoped permissions. Credentials are securely stored in AWS Secrets Manager.

- **🏗️ High Availability Infrastructure**

  - VPC spans 3 AZs with public/private subnet separation
  - Auto Scaling Group (ASG) for app tier across private subnets
  - Multi-AZ RDS PostgreSQL deployment

- **💰 Cost Optimization**

  - Single NAT Gateway (per environment) to reduce cost
  - Lightweight instance types (`t3.micro`, `db.t4g.micro`)
  - Lifecycle policies for S3 log cleanup
  - Auto-deletion for final snapshots disabled in dev

- **⚙️ Automation with Makefile & GitHub Actions**

  - `Makefile` supports per-environment `init`, `plan`, `apply`, `destroy`, etc.
  - GitHub Actions workflow auto-applies to `dev` and `prod` on push to `main`

- **🔒 Security Best Practices**

  - All workloads run in private subnets
  - ALB is the only public-facing endpoint
  - Application security groups strictly scoped to internal traffic
  - S3 buckets are encrypted, versioned, and public access is tightly controlled

---

## 📦 Stack Overview

| Component  | Details                                    |
| ---------- | ------------------------------------------ |
| VPC        | 3 AZs, public/private subnets, NAT Gateway |
| App Tier   | EC2 ASG via Launch Template with user data |
| RDS        | PostgreSQL, multi-AZ, Secrets Manager auth |
| ALB        | HTTP listener, logs to S3, SG-restricted   |
| S3         | Encrypted, versioned, static site + logs   |
| IAM        | EC2 role, ALB log writer, least privilege  |
| Automation | Makefile, GitHub Actions, remote backends  |

---

## 🛠️ Local Usage with Makefile

```bash
make init ENV=dev         # Init Terraform in dev environment
make plan ENV=prod        # Plan for prod
make apply ENV=dev        # Apply infrastructure for dev
make destroy ENV=prod     # Destroy prod environment
```

---

## 🚀 GitHub Actions CI/CD

On every push to `main`, Terraform is:

- Initialized
- Workspace selected or created (`dev`, `prod`)
- Automatically applied for both environments

> AWS credentials must be added as repository secrets:\
> `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

---

## 📁 Project Structure

```
.
├── environments/
│   ├── dev/
│   └── prod/
├── modules/
│   ├── alb/
│   ├── app_tier/
│   ├── iam/
│   ├── rds/
│   ├── s3/
│   └── vpc/
├── backend/
│   └── remote_state.tf
├── Makefile
└── .github/
    └── workflows/
        └── terraform.yml
```

---

## 📌 Requirements

- Terraform 1.12+
- AWS CLI configured (for local usage)
- GitHub repo with `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` set in Actions secrets

---

## 🧽 Next Steps / Optional Enhancements

- DNS + Route 53 for domain routing
- HTTPS via ACM + ALB TLS listener
- Monitoring with CloudWatch + SNS alerts
- Cost estimates with `terraform cost estimation` tools

---

## 📄 License

MIT © Tyler MacPherson

```
```
