---
name: kubernetes-specialist
description: Use when deploying or managing Kubernetes workloads requiring cluster configuration, security hardening, or troubleshooting. Invoke for Helm charts, RBAC policies, NetworkPolicies, storage configuration, performance optimization.
---

# Kubernetes Specialist

## When to Use This Skill

- Deploying workloads (Deployments, StatefulSets, DaemonSets, Jobs)
- Configuring networking (Services, Ingress, NetworkPolicies)
- Managing configuration (ConfigMaps, Secrets, environment variables)
- Setting up persistent storage (PV, PVC, StorageClasses)
- Creating Helm charts for application packaging
- Troubleshooting cluster and workload issues
- Implementing security best practices

## Core Workflow

1. **Analyze requirements** - Understand workload characteristics, scaling needs, security requirements
2. **Design architecture** - Choose workload types, networking patterns, storage solutions
3. **Implement manifests** - Create declarative YAML with proper resource limits, health checks
4. **Secure** - Apply RBAC, NetworkPolicies, Pod Security Standards, least privilege
5. **Test & validate** - Verify deployments, test failure scenarios, validate security posture

## Reference Guide

Load detailed guidance based on context:

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Workloads | `references/workloads.md` | Deployments, StatefulSets, DaemonSets, Jobs, CronJobs |
| Networking | `references/networking.md` | Services, Ingress, NetworkPolicies, DNS |
| Configuration | `references/configuration.md` | ConfigMaps, Secrets, environment variables |
| Storage | `references/storage.md` | PV, PVC, StorageClasses, CSI drivers |
| Helm Charts | `references/helm-charts.md` | Chart structure, values, templates, hooks, testing, repositories |
| Troubleshooting | `references/troubleshooting.md` | kubectl debug, logs, events, common issues |
| Custom Operators | `references/custom-operators.md` | CRD, Operator SDK, controller-runtime, reconciliation |
| Service Mesh | `references/service-mesh.md` | Istio, Linkerd, traffic management, mTLS, canary |
| GitOps | `references/gitops.md` | ArgoCD, Flux, progressive delivery, sealed secrets |
| Cost Optimization | `references/cost-optimization.md` | VPA, HPA tuning, spot instances, quotas, right-sizing |
| Multi-Cluster | `references/multi-cluster.md` | Cluster API, federation, cross-cluster networking, DR |

## Constraints

### MUST DO
- Use declarative YAML manifests (avoid imperative kubectl commands)
- Set resource requests and limits on all containers
- Include liveness and readiness probes
- Use secrets for sensitive data (never hardcode credentials)
- Apply least privilege RBAC permissions
- Implement NetworkPolicies for network segmentation
- Use namespaces for logical isolation
- Label resources consistently for organization
- Document configuration decisions in annotations

### MUST NOT DO
- Deploy to production without resource limits
- Store secrets in ConfigMaps or as plain environment variables
- Use default ServiceAccount for application pods
- Allow unrestricted network access (default allow-all)
- Run containers as root without justification
- Skip health checks (liveness/readiness probes)
- Use latest tag for production images
- Expose unnecessary ports or services
