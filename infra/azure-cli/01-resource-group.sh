#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Étape 1 — Groupe de ressources + variables communes
# En clair : on réserve dans Azure un « dossier » (le groupe de
# ressources) où toutes les machines et services du projet seront
# rangés. On y définit aussi les noms et la région utilisés partout.
# Valeurs génériques (aucune donnée client réelle).
# ──────────────────────────────────────────────────────────────
set -euo pipefail

# Variables partagées par tous les scripts (source ce fichier avant les suivants)
export LOCATION="canadacentral"
export RG="rg-hybrid-infra"
export VNET="vnet-hybrid"
export LAW="law-hybrid"

# Connexion (interactif) : az login
echo "➤ Création du groupe de ressources '$RG' dans '$LOCATION'"
az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --tags projet=infra-hybride environnement=demo

echo "✅ Groupe de ressources prêt."
