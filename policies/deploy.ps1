# deploy.ps1 - PowerShell script for deploying Azure Policies with Bicep

$location = "eastus"  # Change to your desired region
$deploymentName = "policies-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

function Deploy-Policy {
    param (
        [string]$TemplateFile,
        [string]$PolicyName,
        [string]$LocationValue,
        [string]$TagName = $null
    )

    $params = @{
        Name         = $deploymentName
        location     = $location
        TemplateFile = $TemplateFile
        policyName   = $PolicyName
        locationValue= $LocationValue
        Verbose      = $true
    }
    if ($TagName) {
        $params['tagName'] = $TagName
    }

    try {
        New-AzSubscriptionDeployment @params
        Write-Host "Deployed $PolicyName successfully."
    } catch {
        Write-Host "Failed to deploy $($PolicyName): $_" -ForegroundColor Red
        exit 1
    }
}

$policyNamePrefix = "EnforceTaggingPolicy-"


Write-Host "Starting Azure Policies deployment..."

Deploy-Policy -TemplateFile "./costCenterTag.bicep" -PolicyName "$($policyNamePrefix)CostCenter" -LocationValue $location
Deploy-Policy -TemplateFile "./environmentTag.bicep" -PolicyName "$($policyNamePrefix)Environment" -LocationValue $location
Deploy-Policy -TemplateFile "./severityTag.bicep" -PolicyName "$($policyNamePrefix)Severity" -LocationValue $location
Deploy-Policy -TemplateFile "./simpleTag.bicep" -PolicyName "$($policyNamePrefix)AppID" -TagName "App ID" -LocationValue $location
Deploy-Policy -TemplateFile "./simpleTag.bicep" -PolicyName "$($policyNamePrefix)ApplicationName" -TagName "Application Name" -LocationValue $location
Deploy-Policy -TemplateFile "./simpleTag.bicep" -PolicyName "$($policyNamePrefix)AppOwner" -TagName "App Owner" -LocationValue $location
Deploy-Policy -TemplateFile "./inheriteTags.bicep" -PolicyName "$($policyNamePrefix)Inherite" -LocationValue $location

Write-Host "Deployment completed."
