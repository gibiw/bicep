# Azure Infrastructure Deployment

This repository contains Bicep templates for deploying Azure Virtual Desktop (AVD) and Azure Firewall resources.

## Azure Virtual Desktop (AVD)

The AVD deployment creates the following resources:

### Virtual Network
- Creates a virtual network with specified address prefix
- Configures subnets based on provided parameters

### Host Pool
- Creates a pooled host pool with the following configuration:
  - Windows 11 Enterprise (22H2) as the base image
  - Standard_D2s_v3 VM size (2 cores, 8GB RAM)
  - Standard SSD managed disks
  - Automatic session assignment
  - Breadth-first load balancing
  - Scheduled agent updates (Friday 7 AM and Saturday 8 AM)

### Application Group
- Creates a desktop application group
- Associates the application group with the host pool

### Session Host VMs
- Deploys 2 session host VMs with the following configuration:
  - Windows 11 Enterprise (22H2)
  - Standard_D2s_v5 VM size
  - 128GB OS disk
  - Domain join capability
  - Automatic registration with the host pool

## Azure Firewall

The Firewall deployment creates the following resources:

### Virtual Network
- Creates a virtual network with specified address space (default: 10.145.0.0/24)
- Configures a dedicated subnet for Azure Firewall (default: 10.145.0.192/26)

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

## Deployment

Each directory contains deployment scripts for both PowerShell (deploy.ps1) and Bash (deploy.sh) environments. The deployment can be customized using parameter files located in the respective directories.
