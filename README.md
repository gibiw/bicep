# Azure Infrastructure Deployment

This repository contains Bicep templates for deploying Azure Virtual Desktop (AVD) and Azure Firewall resources, along with Azure Policy definitions for resource tagging.

## Project Structure

The repository is organized into three main directories:
- `avd/` - Azure Virtual Desktop deployment
- `firewall/` - Azure Firewall deployment
- `policies/` - Azure Policy definitions for resource tagging

## Prerequisites

Before deploying the infrastructure, ensure you have:
- Azure CLI or Azure PowerShell installed
- Appropriate permissions in the target subscription
- Required service principals or managed identities for deployment
- Network connectivity to Azure services
- Required Azure subscriptions and resource providers enabled

## Architecture Overview

The solution implements a hub-and-spoke network architecture:
- Hub network contains the Azure Firewall for centralized security
- Spoke networks contain AVD resources
- VNet peering connects hub and spoke networks
- Azure Policies ensure consistent resource tagging

## Azure Virtual Desktop (AVD)

The AVD deployment creates the following resources:

### Virtual Network
- Creates a virtual network with specified address prefix
- Configures subnets based on provided parameters
- Supports private endpoints for enhanced security
- Includes VNet peering module for connecting to other virtual networks with the following features:
  - Bidirectional peering configuration
  - Configurable access settings (virtual network access, forwarded traffic)
  - Optional gateway transit support
  - Remote gateway usage options

### Host Pool
- Creates a pooled host pool with the following configuration:
  - Windows 11 Enterprise (22H2) as the base image
  - Standard_D2s_v3 VM size (2 cores, 8GB RAM)
  - Standard SSD managed disks
  - Automatic session assignment
  - Breadth-first load balancing
  - Scheduled agent updates (Friday 7 AM and Saturday 8 AM)
  - Custom RDP properties for enhanced user experience
  - Support for SSO with ADFS integration
  - Optional validation environment for testing new features

### Application Group
- Creates a desktop application group
- Associates the application group with the host pool
- Supports role-based access control (RBAC)

### Session Host VMs
- Deploys 2 session host VMs with the following configuration:
  - Windows 11 Enterprise (22H2)
  - Standard_D2s_v5 VM size
  - 128GB OS disk
  - Domain join capability
  - Automatic registration with the host pool
  - Support for Start VM on Connect feature

## Azure Firewall

The Firewall deployment creates the following resources:

### Virtual Network
- Uses an existing virtual network
- Creates a dedicated subnet for Azure Firewall (default: 10.145.0.192/26)
- Supports private endpoints for enhanced security

### Public IP Address
- Creates a Standard SKU public IP address
- Static allocation method
- Used for the Azure Firewall

### Azure Firewall
- Deploys Azure Firewall with the following configuration:
  - Standard or Premium tier (configurable)
  - Associated with the virtual network
  - Uses the created public IP address
  - Includes default firewall rules

### Firewall Rules
- Deploys a set of firewall rules for the Azure Firewall organized in two rule collection groups:

#### Network Rules (Priority: 100)
- **DNS Rules**:
  - Out-DNS: Allows outbound DNS traffic (UDP/TCP port 53) to specific DNS servers (10.112.1.11, 10.111.1.11)
  - In-DNS: Allows inbound DNS traffic (UDP/TCP port 53) from specific DNS servers
- **Internal Network Rules**:
  - Out-NYL-Open: Allows all outbound traffic to private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
  - In-NYL-Open: Allows all inbound traffic from private IP ranges

#### Application Rules (Priority: 200)
- **Microsoft Services**:
  - allowMicrosoft: Allows HTTP/HTTPS traffic to *.microsoft.com and *.windowsupdate.com
- **Azure Services**:
  - allowAzure: Allows HTTPS traffic to *.azure.com and *.core.windows.net

All rules are configured with 'Allow' action and are applied after the firewall deployment.

## Azure Policies

The repository includes several policy definitions for resource tagging:

### Inherit Tags Policy
- Automatically inherits tags from resource groups to resources
- Enforces the following tags:
  - Cost Center
  - Environment
  - Severity
  - App ID
  - Application Name
  - App Owner

### Additional Tag Policies
- Cost Center Tag Policy
- Environment Tag Policy
- Severity Tag Policy
- Simple Tag Policy

## Deployment

Each directory contains deployment scripts for both PowerShell (deploy.ps1) and Bash (deploy.sh) environments. The deployment can be customized using parameter files located in the respective directories.

### Deployment Steps
1. Clone the repository
2. Navigate to the desired deployment directory (avd or firewall)
3. Update the parameters file with your specific values
4. Run the deployment script:
   ```bash
   # For PowerShell
   ./deploy.ps1
   
   # For Bash
   ./deploy.sh
   ```

### Parameter Files
- `avd/parameters/` - Contains parameter files for AVD deployment

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
