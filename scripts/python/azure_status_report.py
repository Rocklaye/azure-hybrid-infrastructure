#!/usr/bin/env python3
"""Rapport d'état des ressources Azure d'un abonnement.

Interroge Azure Resource Manager via le SDK Python et produit un résumé
(nombre de ressources par type et par région). Sert au suivi et à la
documentation de l'infrastructure hybride.

Dépendances :
    pip install azure-identity azure-mgmt-resource

Authentification (DefaultAzureCredential) :
    az login            # ou variables d'env / identité managée

Usage :
    python azure_status_report.py --subscription <SUBSCRIPTION_ID>
"""

import argparse
from collections import Counter

try:
    from azure.identity import DefaultAzureCredential
    from azure.mgmt.resource import ResourceManagementClient
except ImportError:
    raise SystemExit(
        "Dépendances manquantes : pip install azure-identity azure-mgmt-resource"
    )


def build_report(subscription_id: str) -> None:
    credential = DefaultAzureCredential()
    client = ResourceManagementClient(credential, subscription_id)

    by_type: Counter = Counter()
    by_location: Counter = Counter()
    total = 0

    for res in client.resources.list():
        total += 1
        by_type[res.type] += 1
        by_location[res.location] += 1

    print(f"\n=== Rapport d'état — abonnement {subscription_id} ===")
    print(f"Total de ressources : {total}\n")

    print("Par type :")
    for rtype, count in by_type.most_common():
        print(f"  {count:4d}  {rtype}")

    print("\nPar région :")
    for loc, count in by_location.most_common():
        print(f"  {count:4d}  {loc}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Rapport d'état des ressources Azure")
    parser.add_argument("--subscription", required=True, help="ID d'abonnement Azure")
    args = parser.parse_args()
    build_report(args.subscription)


if __name__ == "__main__":
    main()
