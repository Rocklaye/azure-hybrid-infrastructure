# Supervision — Azure Monitor + Log Analytics

Centraliser métriques, journaux et alertes des ressources Azure (et, via les agents, des VMs) dans un espace de travail Log Analytics unique.

## Composants
- **Log Analytics Workspace** : stockage et requêtes (KQL) des journaux.
- **Azure Monitor Agent (AMA)** + **Data Collection Rules (DCR)** : collecte sur les VMs Linux/Windows.
- **Alertes** : métriques (CPU, mémoire, disque) et requêtes de journaux.

## Mise en place
Voir `infra/azure-cli/04-monitoring.sh`. En résumé :
1. Créer le workspace Log Analytics.
2. Déployer l'agent Azure Monitor sur chaque VM.
3. Associer une DCR (quels compteurs / journaux collecter).
4. Définir les alertes et leurs groupes d'action (notification courriel / webhook).

## Exemples de requêtes KQL

Top 10 des VMs par CPU moyen (dernière heure) :
```kusto
InsightsMetrics
| where Namespace == "Processor" and Name == "UtilizationPercentage"
| summarize avgCpu = avg(Val) by Computer
| top 10 by avgCpu desc
```

Événements de connexion Windows échoués :
```kusto
SecurityEvent
| where EventID == 4625
| summarize tentatives = count() by Account, Computer
| sort by tentatives desc
```

## Bonnes pratiques
- Rétention adaptée au besoin (coût vs conformité).
- Tableaux de bord Azure Monitor Workbooks pour la vue d'exploitation.
- Alertes actionnables uniquement (éviter le bruit).
