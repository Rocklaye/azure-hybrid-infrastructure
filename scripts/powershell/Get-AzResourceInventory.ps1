<#
.SYNOPSIS
    Inventaire des ressources Azure d'un groupe de ressources + export CSV.

.DESCRIPTION
    Parcourt un resource group, liste les ressources (type, emplacement, tags)
    et génère un rapport d'état horodaté. Utilisé pour le suivi et la
    documentation de l'infrastructure hybride.

.EXAMPLE
    ./Get-AzResourceInventory.ps1 -ResourceGroup rg-hybrid-infra

.NOTES
    Prérequis : module Az (Connect-AzAccount déjà effectué).
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [string]$OutFile = "inventaire-$(Get-Date -Format yyyyMMdd-HHmm).csv"
)

Write-Host "➤ Inventaire du groupe de ressources '$ResourceGroup'..."

$resources = Get-AzResource -ResourceGroupName $ResourceGroup |
    Select-Object Name,
                  ResourceType,
                  Location,
                  @{ Name = 'Tags'; Expression = { ($_.Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ';' } }

if (-not $resources) {
    Write-Warning "Aucune ressource trouvée."
    return
}

$resources | Format-Table -AutoSize
$resources | Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8

Write-Host "✅ $($resources.Count) ressources exportées vers $OutFile"
