#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Étape 1 — Groupe de ressources + variables communes
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
