# Infrastructure cloud hybride Azure / on-premise

> **Partie cloud d'une infrastructure d'entreprise hybride** : interconnexion d'un datacenter on-premise avec Microsoft Azure — réseaux virtuels, machines virtuelles, identités synchronisées (Entra ID) et supervision centralisée.

![Azure](https://img.shields.io/badge/Microsoft%20Azure-0078D4?logo=microsoftazure&logoColor=white)
![Bicep](https://img.shields.io/badge/Bicep-IaC-0078D4?logo=microsoftazure&logoColor=white)
![Azure CLI](https://img.shields.io/badge/Azure%20CLI-runbook-0078D4?logo=microsoftazure&logoColor=white)
![Entra ID](https://img.shields.io/badge/Entra%20ID-identit%C3%A9%20hybride-0078D4?logo=microsoftentra&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-automatisation-5391FE?logo=powershell&logoColor=white)
![Python](https://img.shields.io/badge/Python-reporting-3776AB?logo=python&logoColor=white)

---

> ⚠️ **Note de confidentialité.** Ce dépôt documente **l'architecture et la démarche de déploiement** de la partie cloud d'une infrastructure d'entreprise à laquelle j'ai contribué. Les scripts, schémas et valeurs sont **génériques et reconstitués à des fins de documentation** : ils ne contiennent **aucune donnée, nom de domaine, adresse IP, identifiant ou secret réels** du client. L'objectif est de montrer la méthode et les commandes, pas de republier une configuration de production.

## 🎯 Objectif

Décrire, de bout en bout, comment est déployée et exploitée la partie Azure d'une infrastructure hybride : connecter le réseau on-premise à Azure, y héberger des charges de travail, unifier les identités et superviser l'ensemble depuis un point central.

## 🏗️ Architecture

![Architecture hybride Azure / on-premise](docs/architecture.svg)

```
  On-premise (datacenter)                      Microsoft Azure
  ┌───────────────────────┐   VPN S2S   ┌──────────────────────────────────┐
  │ Active Directory DS   │◄───────────►│ VNet 10.10.0.0/16                 │
  │ Serveurs / Hyper-V    │  (IPSec)    │  ├─ GatewaySubnet → VPN Gateway   │
  │ Azure AD Connect ─────┼──sync──────►│  ├─ snet-app  → VM Linux / Windows│
  └───────────────────────┘             │  └─ snet-mgmt → administration    │
                                        │ Entra ID (identités hybrides)     │
                                        │ Azure Monitor + Log Analytics     │
                                        └──────────────────────────────────┘
```

## 🧩 Composants Azure configurés

| Domaine | Composants |
|---------|-----------|
| Réseau | VNet, sous-réseaux, NSG, `GatewaySubnet`, **passerelle VPN site-to-site** vers l'on-premise |
| Calcul | VMs **Linux** et **Windows Server** (tailles B-series), disques managés |
| Identité | **Entra ID**, synchronisation **Azure AD Connect** avec l'AD on-premise, rôles **RBAC** |
| Supervision | **Azure Monitor**, **Log Analytics**, agents sur les VMs, alertes |
| Automatisation | Scripts **PowerShell** et **Python** : inventaire des ressources et rapports d'état |

## 📂 Structure

```
azure-hybrid-infrastructure/
├── README.md
├── infra/
│   ├── azure-cli/           # Runbook pas-à-pas (montre les actions, commande par commande)
│   │   ├── 01-resource-group.sh
│   │   ├── 02-network.sh
│   │   ├── 03-compute.sh
│   │   └── 04-monitoring.sh
│   └── bicep/               # Même infrastructure en Infrastructure-as-Code
│       ├── main.bicep
│       └── README.md
├── scripts/
│   ├── powershell/Get-AzResourceInventory.ps1
│   └── python/azure_status_report.py
└── docs/
    ├── architecture.svg
    ├── deployment-guide.md   # Déroulé complet du déploiement
    ├── hybrid-identity.md     # Entra ID + Azure AD Connect
    └── monitoring.md          # Azure Monitor + Log Analytics
```

## 🚀 Déploiement

Deux façons de reproduire l'infrastructure (voir [`docs/deployment-guide.md`](docs/deployment-guide.md)) :

1. **Runbook Azure CLI** — exécuter dans l'ordre les scripts de [`infra/azure-cli/`](infra/azure-cli/) ; chaque commande est commentée pour montrer l'action réalisée.
2. **Bicep (IaC)** — déployer [`infra/bicep/main.bicep`](infra/bicep/main.bicep) d'un coup, de manière idempotente.

## 🧰 Stack

Azure (VNet, VM, VPN Gateway, Entra ID, Azure Monitor) · Bicep · Azure CLI · PowerShell (module `Az`) · Python (`azure-identity`, `azure-mgmt-*`)

---

*Projet maintenu par [Abdoulaye Aw](https://github.com/Rocklaye) — Infrastructure réseaux, IoT et cybersécurité.*
