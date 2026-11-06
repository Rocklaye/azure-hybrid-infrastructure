#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Étape 3 — Calcul : VMs Linux et Windows Server dans snet-app
# Prérequis : 01 et 02 exécutés.
# Bonne pratique : mots de passe / clés via Azure Key Vault, jamais en clair.
# ──────────────────────────────────────────────────────────────
set -euo pipefail
: "${RG:?}" "${VNET:?}"

echo "➤ VM Linux (Ubuntu 22.04) — clé SSH générée"
az vm create \
  --resource-group "$RG" --name vm-linux \
  --image Ubuntu2204 --size Standard_B1s \
  --vnet-name "$VNET" --subnet snet-app \
  --admin-username azureuser --generate-ssh-keys \
  --public-ip-address "" --nsg ""

echo "➤ VM Windows Server 2022 — mot de passe récupéré depuis Key Vault"
# az keyvault secret show ... (ne jamais coder le secret en dur)
WINPWD="$(az keyvault secret show --vault-name <KEYVAULT> --name vm-win-admin --query value -o tsv 2>/dev/null || echo '<DEFINIR_VIA_KEYVAULT>')"
az vm create \
  --resource-group "$RG" --name vm-win \
  --image Win2022Datacenter --size Standard_B2s \
  --vnet-name "$VNET" --subnet snet-app \
  --admin-username azureuser --admin-password "$WINPWD" \
  --public-ip-address "" --nsg ""

echo "✅ VMs déployées (accès via la passerelle VPN / Bastion, pas d'IP publique)."
