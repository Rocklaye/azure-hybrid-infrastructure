#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Étape 4 — Supervision : Log Analytics + Azure Monitor sur les VMs
# En clair : on branche l'« écran de contrôle ». On collecte les
# mesures et les journaux des machines au même endroit, et on crée
# une alerte automatique (ex. : prévenir si un serveur est surchargé).
# Prérequis : 01 à 03 exécutés.
# ──────────────────────────────────────────────────────────────
set -euo pipefail
: "${RG:?}" "${LAW:?}" "${LOCATION:?}"

echo "➤ Espace de travail Log Analytics"
az monitor log-analytics workspace create \
  --resource-group "$RG" --workspace-name "$LAW" --location "$LOCATION"

WSID="$(az monitor log-analytics workspace show -g "$RG" -n "$LAW" --query id -o tsv)"

echo "➤ Agent Azure Monitor + règle de collecte (DCR) associés aux VMs"
for VM in vm-linux vm-win; do
  az vm extension set \
    --resource-group "$RG" --vm-name "$VM" \
    --name AzureMonitorLinuxAgent --publisher Microsoft.Azure.Monitor \
    2>/dev/null || \
  az vm extension set \
    --resource-group "$RG" --vm-name "$VM" \
    --name AzureMonitorWindowsAgent --publisher Microsoft.Azure.Monitor
done

echo "➤ Exemple d'alerte : CPU moyen > 80% sur 5 min"
az monitor metrics alert create \
  --resource-group "$RG" --name alert-cpu-high \
  --scopes "$(az vm show -g "$RG" -n vm-linux --query id -o tsv)" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m \
  --description "CPU élevé sur vm-linux"

echo "✅ Supervision active (métriques + journaux centralisés dans $LAW)."
echo "ℹ️  Workspace: $WSID"
