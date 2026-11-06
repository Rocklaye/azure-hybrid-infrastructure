# Identité hybride — Entra ID + Azure AD Connect

Unifier les identités entre l'Active Directory on-premise et Microsoft Entra ID, pour une authentification cohérente sur les ressources locales et cloud.

## Principe

```
AD DS (on-premise)  ──  Azure AD Connect  ──►  Microsoft Entra ID
   utilisateurs            synchronisation          utilisateurs synchronisés
   groupes                 (toutes les 30 min)      + rôles RBAC Azure
```

## Étapes

1. **Préparer l'AD on-premise** : UO, utilisateurs et groupes propres ; vérifier les UPN (suffixe routable aligné avec le domaine Entra).
2. **Installer Azure AD Connect** sur un serveur membre :
   - Méthode d'authentification : *Password Hash Synchronization* (simple et résilient) ou *Pass-through Authentication* selon le besoin.
   - Filtrage par UO pour ne synchroniser que le périmètre voulu.
3. **Lancer et vérifier la synchronisation** :
   - Portail Entra → *Utilisateurs* → statut « synchronisé depuis Windows Server AD ».
   - `Start-ADSyncSyncCycle -PolicyType Delta` pour forcer un cycle.
4. **Attribuer les rôles RBAC Azure** aux groupes synchronisés (principe du moindre privilège) :
   ```bash
   az role assignment create \
     --assignee <objectId-du-groupe> \
     --role "Virtual Machine Contributor" \
     --resource-group rg-hybrid-infra
   ```
5. **Durcissement** : MFA via *Conditional Access*, comptes d'administration séparés, revue périodique des accès.

## Points de vigilance
- Ne jamais synchroniser les comptes à hauts privilèges du domaine.
- Surveiller les erreurs de synchronisation (Entra Connect Health).
- Documenter le périmètre synchronisé (quelles UO, quels attributs).
