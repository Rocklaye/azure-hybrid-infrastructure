# Déploiement Bicep

Déploie le réseau, la supervision et une VM Linux de façon idempotente.

## Prérequis
- Azure CLI avec l'extension Bicep (`az bicep install`)
- Un groupe de ressources existant

## Déploiement

```bash
az group create -n rg-hybrid-infra -l canadacentral

az deployment group create \
  --resource-group rg-hybrid-infra \
  --template-file main.bicep \
  --parameters \
      prefix=hybrid \
      linuxSshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
      windowsAdminPassword="@Microsoft.KeyVault(SecretUri=https://<kv>.vault.azure.net/secrets/vm-win-admin)"
```

> Le mot de passe Windows et la clé partagée VPN ne sont **jamais** écrits en clair : ils proviennent d'Azure Key Vault (référence `@Microsoft.KeyVault(...)`).

## Fichiers
- `main.bicep` — réseau (VNet, sous-réseaux, NSG, GatewaySubnet), Log Analytics, appel du module VM
- `modules/vm-linux.bicep` — carte réseau + VM Linux sans IP publique
