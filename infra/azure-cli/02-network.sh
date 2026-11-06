#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Étape 2 — Réseau : VNet, sous-réseaux, NSG et passerelle VPN
# En clair : on construit le réseau privé du cloud (les « pièces »
# où iront les machines), on met un videur a l'entree (le NSG qui
# filtre le trafic), puis on ouvre le tunnel securise (VPN) vers les
# serveurs de l'entreprise.
# Prérequis : avoir sourcé 01-resource-group.sh
# ──────────────────────────────────────────────────────────────
set -euo pipefail
: "${RG:?source 01-resource-group.sh en premier}" "${VNET:?}"

echo "➤ VNet + sous-réseau applicatif"
az network vnet create \
  --resource-group "$RG" --name "$VNET" \
  --address-prefixes 10.10.0.0/16 \
  --subnet-name snet-app --subnet-prefix 10.10.1.0/24

echo "➤ Sous-réseau d'administration"
az network vnet subnet create \
  --resource-group "$RG" --vnet-name "$VNET" \
  --name snet-mgmt --address-prefixes 10.10.2.0/24

echo "➤ GatewaySubnet (obligatoire pour la passerelle VPN)"
az network vnet subnet create \
  --resource-group "$RG" --vnet-name "$VNET" \
  --name GatewaySubnet --address-prefixes 10.10.255.0/27

echo "➤ NSG + règle SSH restreinte, appliqué au sous-réseau applicatif"
az network nsg create --resource-group "$RG" --name nsg-app
az network nsg rule create \
  --resource-group "$RG" --nsg-name nsg-app --name allow-ssh \
  --priority 1000 --direction Inbound --access Allow --protocol Tcp \
  --destination-port-ranges 22 --source-address-prefixes '<IP_ADMIN/32>'
az network vnet subnet update \
  --resource-group "$RG" --vnet-name "$VNET" --name snet-app \
  --network-security-group nsg-app

echo "➤ Passerelle VPN site-to-site vers le site on-premise"
az network public-ip create --resource-group "$RG" --name pip-vpngw --sku Standard
# Provisionnement long (~30-45 min) :
az network vnet-gateway create \
  --resource-group "$RG" --name vpngw-hybrid \
  --vnet "$VNET" --gateway-type Vpn --vpn-type RouteBased \
  --sku VpnGw1 --public-ip-addresses pip-vpngw --no-wait
# La local-network-gateway (représentant le site on-prem) et la connexion IPSec :
#   az network local-gateway create  ... --gateway-ip-address <IP_PUBLIQUE_ONPREM> --local-address-prefixes <RESEAU_ONPREM>
#   az network vpn-connection create  ... --shared-key <PSK-via-Key-Vault>
echo "ℹ️  Voir docs/deployment-guide.md pour la connexion IPSec complète."
echo "✅ Réseau configuré."
