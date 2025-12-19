# AWS Monitoring Stack
Terraform + Ansible + Grafana + Prometheus + Loki

## Overview
This project deploys a AWS-based monitoring and observability stack using **Terraform** for infrastructure and **Ansible** for configuration management.

Metrics are collected by **Prometheus** via direct scraping of system exporters and application endpoints.  
Logs are collected and shipped to **Loki** using **Grafana Alloy** agents.  
**Grafana** acts as the unified visualization and alerting layer.

All Grafana datasources and dashboards are **automatically provisioned via Ansible**.  
No manual UI configuration is required.

---

## Application & Monitoring Flow
- Prometheus scrapes:
  - Node Exporter (system metrics)
  - Flask application `/metrics` endpoint
- Grafana Alloy runs on the Application EC2:
  - Collects system and application logs
  - Pushes logs to Loki
- Grafana queries:
  - Prometheus for metrics
  - Loki for logs

---

## High-Level Architecture

The infrastructure consists of **five EC2 instances**:

1. **Ansible Control Node**
   - Executes Ansible playbooks
   - Manages all other EC2 instances

2. **Grafana EC2**
   - Grafana UI (TCP 3000)
   - Queries Prometheus and Loki

3. **Prometheus EC2**
   - Prometheus server (TCP 9090)
   - Scrapes metrics from exporters and applications

4. **Loki EC2**
   - Loki log storage (TCP 3100)
   - Receives logs from Alloy agents

5. **Application EC2**
   - Nginx (HTTP entrypoint)
   - Flask backend application
   - Node Exporter (metrics)
   - Grafana Alloy (log collection)

---

## Network & Access Flow
- Internet / Users  
  → TCP 80 → Application EC2

- Admin IPs  
  → TCP 3000 → Grafana EC2

- Grafana EC2  
  → TCP 9090 → Prometheus EC2  
  → TCP 3100 → Loki EC2

- Prometheus EC2  
  → TCP 9100 → Node Exporter  
  → TCP 5000 → Flask `/metrics`

- Grafana Alloy (Application EC2)  
  → TCP 3100 → Loki EC2

---

## Metrics Flow (Prometheus)
1. Node Exporter exposes system metrics (CPU, memory, disk, load)
2. Flask application exposes `/metrics`
3. Prometheus scrapes all targets
4. Grafana visualizes metrics via dashboards and alerts

---

## Logging Flow (Loki)
1. Flask and Nginx generate logs on Application EC2
2. Grafana Alloy:
   - Tails log files
   - Adds labels
   - Pushes logs to Loki
3. Loki stores logs
4. Grafana queries and visualizes logs

---

## Repository Structure

```
aws-monitoring/
├── ansible/
│   ├── ansible.cfg
│   ├── inventory
│   ├── playbook.yml
│   ├── roles/
│   │   ├── grafana/
│   │   │   ├── defaults/
│   │   │   ├── handlers/
│   │   │   ├── tasks/
│   │   │   ├── templates/
│   │   │   └── files/
│   │   │       └── dashboards/
│   │   ├── prometheus/
│   │   ├── loki/
│   │   ├── node/
│   │   ├── alloy/
│   │   ├── flask/
│   │   └── stress/
│   └── terraform.tfstate
│
└── infra/
    ├── env/
    │   └── dev/
    ├── modules/
    │   ├── ec2/
    │   ├── iam/
    │   ├── keypair/
    │   ├── rds/
    │   ├── security-group/
    │   └── user-data/
    └── templates/
```

---

## Deployment Flow

1. **Terraform Apply**
   - Provisions AWS infrastructure
   - Generates Ansible inventory and deploy script

2. **Deployment Script**
   - Executes Ansible playbook from control node

3. **Ansible**
   - Installs and configures services
   - Provisions Grafana datasources and dashboards
   - Starts all systemd services

---

## Grafana Dashboards
Provisioned automatically via Ansible:
- HTTP request rate and latency
- CPU, memory, disk usage
- Application warnings and errors via Loki

---

## Alerting & Notifications
- Prometheus evaluates alert rules
- Grafana handles alerting
- Notifications are sent to **Slack**

---