// ──────────────────────────────────────────────────────────────
// Infrastructure hybride Azure — réseau, calcul et supervision
// Déploiement idempotent (Infrastructure-as-Code).
// Valeurs génériques, aucun secret en dur (voir @secure()).
// ──────────────────────────────────────────────────────────────

@description('Région de déploiement')
param location string = resourceGroup().location

@description('Préfixe de nommage')
param prefix string = 'hybrid'

@description('Nom d\'utilisateur admin des VMs')
param adminUsername string = 'azureuser'

@description('Mot de passe admin Windows (fourni via Key Vault / paramètre sécurisé)')
@secure()
param windowsAdminPassword string

@description('Clé publique SSH pour la VM Linux')
param linuxSshPublicKey string

var vnetName = 'vnet-${prefix}'
var lawName  = 'law-${prefix}'

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-app'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-ssh'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: [ '10.10.0.0/16' ] }
    subnets: [
      {
        name: 'snet-app'
        properties: {
          addressPrefix: '10.10.1.0/24'
          networkSecurityGroup: { id: nsg.id }
        }
      }
      { name: 'snet-mgmt', properties: { addressPrefix: '10.10.2.0/24' } }
      { name: 'GatewaySubnet', properties: { addressPrefix: '10.10.255.0/27' } }
    ]
  }
}

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

module linuxVm 'modules/vm-linux.bicep' = {
  name: 'vm-linux'
  params: {
    location: location
    subnetId: '${vnet.id}/subnets/snet-app'
    adminUsername: adminUsername
    sshPublicKey: linuxSshPublicKey
  }
}

output vnetId string = vnet.id
output workspaceId string = law.id
