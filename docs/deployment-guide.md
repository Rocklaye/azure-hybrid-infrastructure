# Guide de déploiement — infrastructure hybride Azure

Déroulé complet pour reproduire l'architecture. Deux approches : runbook Azure CLI (pédagogique, commande par commande) ou Bicep (idempotent).

> Toutes les valeurs sont génériques. Les secrets (mots de passe VM, clé partagée VPN) passent par **Azure Key Vault**, jamais en clair.

## 0. Prérequis
- Azure CLI (`az`) et l'extension Bicep (`az bicep install`)
- Un abonnement Azure et les droits **Contributor** sur le groupe de ressources
- `az login`

## 1. Réseau (côté Azure)
```bash
source infra/azure-cli/01-resource-group.sh
bash   infra/azure-cli/02-network.sh
```
Crée le VNet `10.10.0.0/16`, les sous-réseaux `snet-app` / `snet-mgmt` / `GatewaySubnet`, le NSG, et provisionne la **passerelle VPN**.

## 2. Connexion site-to-site vers l'on-premise
La passerelle VPN Azure est reliée au pare-feu/routeur on-premise :

```bash
# Passerelle réseau locale = représentation du site on-premise
az network local-gateway create -g "$RG" -n lng-onprem \
  --gateway-ip-address <IP_PUBLIQUE_ONPREM> \
  --local-address-prefixes <RESEAU_ONPREM/24>

# Connexion IPSec (clé partagée depuis Key Vault)
az network vpn-connection create -g "$RG" -n cnx-onprem \
  --vnet-gateway1 vpngw-hybrid --local-gateway2 lng-onprem \
  --shared-key "$(az keyvault secret show --vault-name <KV> --name vpn-psk --query value -o tsv)"
```
Côté on-premise, le pare-feu est configuré en miroir (même PSK, mêmes réseaux).

## 3. Identité hybride
Voir [`hybrid-identity.md`](hybrid-identity.md) — Azure AD Connect synchronise l'AD on-premise vers Entra ID, puis attribution des rôles **RBAC**.

## 4. Calcul
```bash
bash infra/azure-cli/03-compute.sh
```
VMs Linux et Windows dans `snet-app`, sans IP publique (accès via VPN ou Azure Bastion).

## 5. Supervision
```bash
bash infra/azure-cli/04-monitoring.sh
```
Voir [`monitoring.md`](monitoring.md).

## 6. Vérification / reporting
```bash
pwsh scripts/powershell/Get-AzResourceInventory.ps1 -ResourceGroup rg-hybrid-infra
python scripts/python/azure_status_report.py --subscription <SUBSCRIPTION_ID>
```

## Alternative Bicep
```bash
az deployment group create -g rg-hybrid-infra \
  --template-file infra/bicep/main.bicep \
  --parameters linuxSshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
               windowsAdminPassword="@Microsoft.KeyVault(SecretUri=...)"
```
