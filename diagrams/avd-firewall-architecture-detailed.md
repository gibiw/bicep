Open this in https://mermaid.live/ to see the diagram.

```mermaid
graph TB
    subgraph "Azure Virtual Desktop"
        subgraph "AVD Host Pool"
            HP[Host Pool]
            SH[Session Hosts]
            HP --> SH
        end
        
        subgraph "AVD Workspace"
            WS[Workspace]
            APP[Application Groups]
            WS --> APP
            APP --> HP
        end
        
        subgraph "AVD Service"
            AVD[AVD Service]
            AVD --> WS
        end

        subgraph "AVD Network"
            AVNET[AVD Virtual Network]
            AVSN[AVD Subnet]
            AVNET --> AVSN
            AVSN --> SH
        end
    end

    subgraph "Network Security"
        subgraph "Azure Firewall"
            FW[Firewall]
            FWP[Firewall Policy]
            FW --> FWP
            
            subgraph "Network Rules"
                NR[Network Rule Collection]
                NR1[Out-DNS]
                NR2[In-DNS]
                NR3[Out-NYL-Open]
                NR4[In-NYL-Open]
                NR --> NR1
                NR --> NR2
                NR --> NR3
                NR --> NR4
            end
            
            subgraph "Application Rules"
                AR[Application Rule Collection]
                AR1[allowMicrosoft]
                AR2[allowAzure]
                AR --> AR1
                AR --> AR2
            end
            
            FWP --> NR
            FWP --> AR
        end
        
        subgraph "Firewall Network"
            FVNET[Firewall Virtual Network]
            FWSN[AzureFirewallSubnet]
            FVNET --> FWSN
            FWSN --> FW
        end
    end

    subgraph "External Services"
        MS[Microsoft Services]
        AZ[Azure Services]
        DNS[DNS Servers]
    end

    %% VNet Peering
    AVNET <--> FVNET

    %% Connections
    SH --> AVNET
    FVNET --> FW
    FW --> MS
    FW --> AZ
    FW --> DNS
    
    %% Styling
    classDef azure fill:#0072C6,stroke:#333,stroke-width:2px,color:white
    classDef security fill:#FF0000,stroke:#333,stroke-width:2px,color:white
    classDef network fill:#00A2ED,stroke:#333,stroke-width:2px,color:white
    classDef external fill:#999,stroke:#333,stroke-width:2px,color:white
    
    class HP,SH,WS,APP,AVD azure
    class FW,FWP,NR,AR security
    class AVNET,AVSN,FVNET,FWSN network
    class MS,AZ,DNS external
```

# Detailed AVD and Firewall Architecture

This diagram shows the detailed architecture of Azure Virtual Desktop (AVD) and Azure Firewall components in our infrastructure.

## Components

### Azure Virtual Desktop
- **Host Pool**: Contains session hosts for user connections
- **Workspace**: Manages application groups and host pool assignments
- **Application Groups**: Groups of applications available to users
- **Session Hosts**: Virtual machines running the AVD service
- **AVD Virtual Network**: Dedicated network for AVD resources
- **AVD Subnet**: Subnet for session hosts

### Network Security
- **Azure Firewall**: Central network security component
- **Firewall Policy**: Defines security rules and configurations
- **Network Rules**:
  - Out-DNS: Allows outbound DNS traffic
  - In-DNS: Allows inbound DNS traffic
  - Out-NYL-Open: Allows outbound traffic to private networks
  - In-NYL-Open: Allows inbound traffic from private networks
- **Application Rules**:
  - allowMicrosoft: Allows traffic to Microsoft services
  - allowAzure: Allows traffic to Azure services
- **Firewall Virtual Network**: Dedicated network for firewall
- **AzureFirewallSubnet**: Dedicated subnet for the firewall

### External Services
- **Microsoft Services**: Required Microsoft endpoints
- **Azure Services**: Required Azure endpoints
- **DNS Servers**: Internal and external DNS servers

## Network Architecture
- AVD resources are deployed in a dedicated virtual network
- Firewall is deployed in a separate virtual network
- VNet peering is configured between AVD and Firewall networks
- All external traffic from AVD goes through the firewall

## Traffic Flow
1. User connects to AVD service
2. AVD service routes to appropriate session host
3. Session host traffic goes through AVD VNet
4. Traffic is routed through VNet peering to Firewall VNet
5. Firewall applies network and application rules
6. Allowed traffic reaches external services
