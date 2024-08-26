# ailzfinal

# Terraform AI landing zone creation

This Terraform file contains the configuration for deploying various Azure AI landing zone resources. Use this to integrate with existing landing zone resources. It initializes data sources, local variables, and modules to create storage accounts, key vaults, log analytics workspaces, application insights instances, container registries, search services, ai studio, ai project, private endpoints for all PaaS services, Azure openai service,Applied AI Services, role-based access control, and diagnostic settings. 


![AILZ-Generic drawio](https://github.com/user-attachments/assets/b803fe4c-0c5e-4705-84ce-7a7af3ec8978)


The code start with instantiating various modules from main.tf. Description is as follows

## Data Sources

- `azurerm_subscription.current`: Retrieves information about the current Azure subscription.
- `azurerm_resource_group.rg`: Retrieves information about the specified resource group.
- `azurerm_subnet.this`: Retrieves information about the specified subnet.

## Resources

- `random_id.random`: Generates a random ID with a specified byte length.

## Local Variables

- `sufix`: A suffix used for resource names if `use_random_suffix` is enabled.
- `name_sufix`: The name suffix to be appended to resource names if `use_random_suffix` is enabled.
- `resource_group_name`: The name of the resource group.
- `storage_account_name`: The name of the storage account.
- `keyvault_name`: The name of the key vault.
- `log_name`: The name of the log analytics workspace.
- `appi_name`: The name of the application insights instance.
- `acr_name`: The name of the container registry.
- `search_name`: The name of the search service.
- `mlw_name`: The name of the machine learning workspace.
- `private_endpoints`: An empty list for private endpoints.
- `private_endpoints_ai`: An empty object for private endpoints related to AI.

## Modules

- `module.st`: Creates a storage account.
- `module.kv`: Creates a key vault.
- `module.logs`: Creates a log analytics workspace.
- `module.appi`: Creates an application insights instance.
- `module.cr`: Creates a container registry.
- `module.search`: Creates a search service.
- `module.ai`: Creates a machine learning workspace.
- `module.pe`: Creates private endpoints.
- `module.openai`: Creates an openai service.
- `module.rbac`: Creates role-based access control.
- `module.diagnostics`: Creates a diagnostic setting.

```markdown
The documentation corresponding to three very important modules are belwo. Please refer to the other individual module files for more detailed documentation on each resource.
```

# AI Module
Following are the details of what each module does 

This Terraform module creates resources for an AI Studio and AI Project in Azure. It provisions an AI Studio workspace and an AI Project within the workspace. The module also creates private endpoints for the AI Studio and project.

## Requirements

- Terraform version 0.13 or higher
- Azure AI provider version 2.0 or higher

# Private Endpoint Module

This module is used to create private endpoints in Azure. Private endpoints allow you to securely access Azure services over a private network connection.

## Inputs

- `virtual_network_name` (required): The name of the virtual network where the private endpoint will be created.
- `virtual_network_resource_group_name` (required): The resource group name of the virtual network.
- `private_endpoints_subnet_name` (required): The name of the subnet where the private endpoint will be placed.
- `private_dns_zone_resource_group_name` (required): The resource group name of the private DNS zone.
- `private_endpoints` (required): A list of private endpoint configurations. Each configuration should include the following properties:
    - `privateEndpointName`: The name of the private endpoint.
    - `resourceGroupName`: The resource group name of the private endpoint.
    - `privateDnsZoneName`: The name of the private DNS zone.
    - `resourceId`: The resource ID of the service to be connected to the private endpoint.
    - `privateEndpointGroupId`: The ID of the private endpoint group.


    # Module: aiservices

    ## Description
    This Terraform module provisions Azure Cognitive Services resources, including an Open AI account and private endpoint for the same.

    ## Inputs
    - `cognitive_name`: The name of the cognitive account. (string)
    - `cognitive_kind`: The kind of cognitive account. (string)
    - `cognitive_sku`: The SKU name of the cognitive account. (string)
    - `location`: The location where the resources will be provisioned. (string)
    - `resource_group_name`: The name of the resource group where the resources will be created. (string)
    - `virtual_network_name`: The name of the virtual network where the private endpoints will be created. (string)
    - `virtual_network_resource_group_name`: The name of the resource group where the virtual network is located. (string)
    - `private_endpoints_subnet_name`: The name of the subnet where the private endpoints will be created. (string)
    - `private_dns_zone_name`: The name of the private DNS zone. (string)
    - `private_dns_zone_resource_group_name`: The name of the resource group where the private DNS zone is located. (string)
    - `tags`: Tags to be assigned to the private endpoint resources. (map)

    ## Outputs
    - `cognitive_account_id`: The ID of the cognitive account.
    - `private_endpoint_ids`: The IDs of the private endpoints.

## Environment Validation:

#### 1. Ensure the below role assignments are in place

| Role                              | Managed Identity                  | Resource |
|----------                         |----------                         |----------|
| Storage File Data Privileged Contributor   | Azure AI Studio project   | Storage Account |
| Storage Blob Data Contributor   | Azure AI Service   | Data 6  |  Storage Account |
| Storage Blob Data Contributor    |    Azure AI Search         |  Storage Account   |

#### 2. Ensure all the private DNS zones are created and configured

#### 3. Validate chat playgrounds and assistant playgrounds are functional

#### 4. Ensure you create an OpenAI connection to the AI landing zone specific OpenAI service. It comes pre-deployed with inputs provided in tfvars. 

#### 5. Create compute instances as needed using information in following link:
https://learn.microsoft.com/en-us/azure/machine-learning/how-to-create-compute-instance?view=azureml-api-2&tabs=azure-cli

#### 6. Check every AI engineers have Azure AI developer role in AI project 

#### 7. Ensure you have individual permissions based on your role on backend storage, file system, search service contributor and cognitive services contributor on the OpenAI service

#### 8. Test serverless compute
        1.  Create a prompt flow
        2.  Start the serverless compute and ensure the green check mark is being displayed on the portal
        
#### 9. If you are a super user and requires dedicated compute, you can create your own compute and configure VS code container on that compute
