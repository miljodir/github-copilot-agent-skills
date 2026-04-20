---
name: "Instructions for using Terraform"
description: "Create or modify solutions built using Terraform on Azure."
applyTo: "**/*.tf"
excludeAgent: []
---

## Coding style

- Follow the coding style defined in the [tflint file](/platform/.tflint.hcl).
- Naming of our resources start with `${local.workload}` and relevant suffixes. In `miljodir` modules the resource names are usually generated based on the module inputs.
- Do not set diagnostic settings unless explicitly requested. These are set with Azure Policy outside this repository
- Terraform resource and data properties should use generic names and locals to supply the specific values where needed.
- In root modules, use locals over variables is preferred when possible
- Our resources should not explicitly specify tags.
- Group related attributes together within blocks.
  - Specify common properties such as name, display_name, location, and resource_group_name at the top of the resource block (if required)
  - Place required attributes before optional ones
  - Separate attribute sections with blank lines to improve readability
- Group related resources together in the same file.
  - Use a consistent naming convention (e.g., `providers.tf`, `variables.tf`, `network.tf`, `sql.tf`, `main.tf`).
- Place `lifecycle` blocks at the very end of resource definitions.
- Place `depends_on` blocks at the end of resource definitions to make dependency relationships clear.
  - Use `depends_on` only when necessary to avoid circular dependencies.
- Place `for_each` and `count` blocks at the beginning of resource definitions to clarify the resource's instantiation logic.
  - `for_each` is preferred over count for resource iteration, except when evaluating a boolean expression
- Do not generate code containing passwords
  - Do not use the `random_password` resource outside modules unless explicitly requested
- location parameters should be = `module.shared.resource_location["default_region"]`
- The terraform syntax should match the version 1.5.5 or greater
  - Resources in the azuread provider should always match the syntax of version 3.0 or greater
  - Resources in the azurerm provider should always match the syntax of version 4.0 or greater
  - Resources in the azapi provider should always match the syntax of version 2.0 or greater
- We do not use the `data "azuread_client_config"` or the `data "azurerm_subscription"` resources directly
  - The available data can be found within the `module.shared` module

- Only create `azurerm_role_assignment` resources for Azure roles which grant DataActions, e.g. `Key Vault Secrets User`, `Storage Blob Data Contributor`.
  - Do not assign Action centric roles such as `Contributor`, `Storage Account Contributor` or `Owner` unless explicitly requested.
  - Explicitly specifiy the attribute `principal_type`
  - Do not grant role assignments to `User` principal_type unless explicitly requested, only grant to `Group` or `ServicePrincipal`
  - Role assignments should usually only be assigned to `workload_identities` and `contributors` groups, and specific service principals if relevant

## Folder structure

```
├── .github/workflows/ # Various GitHub Actions workflows for Terraform plan and apply. Triggered by pull request and push changes to platform/** folders
├── modules
│   └── (local modules for this solution, normally empty)
├── platform
│   ├── dev        # development environment folder
│   ├── test       # test environment folder
│   └── production # production environment
└── README.md # Documentation
```
- Each of the platform/* folders represent a separate environment / Azure subscription. The names of the subsription correlate to the value of `local.workload`
When Coding Agents are experimenting/testing, the platform/dev folder should be used if present.

## Presumptions

- Do not explicitly set tenant_id unless requested, presume this is set already for providers and `miljodir` modules
- Presume existing azuread_group data resources have the following symbolic and display names:
  - `readers` = display_name = "az rbac sub ${local.workload} readers"
  - `contributors` = display_name = "az rbac sub ${local.workload} contributors"
  - `owners` = display_name = "az rbac sub ${local.workload} owners"
  - `workload_identities = display_name = "aks rbac ns ${local.env}-aks-${local.repo} workload identities"`
- Do not specify provider blocks when asked to generate resources, presume these are already set in the providers.tf file
- Do not generate locals named "workload", "subnets" or "generated_suffix", these already exist. The subnets local uses the function `cidrsubnets` over an allocated range.
- Do not generate virtual networks, subnets, private endpoints, NICs or other resources outside modules unless asked to do so. Presume these are already in place unless explicitly requested.
- Backup policies for Azure SQL databases are managed outside this repository using Azure Policy.
- The production environment will typically need more resources than the dev and test environments, e.g. larger SQL sku.
- Local / no redundancy is usually sufficient for dev and test environments unless otherwise specified.
- AzureRM Resource providers must be explicitly set in the providers.tf file in the section `resource_providers_to_register = []`. Do not specify more providers than needed.


### Running terraform commands

- The terraform state is stored in a remote Azure Blob Storage.
  - Terraform init and plan may be run locally, but unless using bash you may struggle to have access to the required modules. The preferred method for terraform commands is to use the existing Github Actions workflows
  - On pull requests, Github Actions are run to format, validate, document and plan the changes.
  - On push to the main branch, Github Actions are run to apply the changes to the relevant target environment(s).
  - Before running `terraform plan` locally, make sure you set the environment variable `ARM_RESOURCE_PROVIDER_REGISTRATIONS="none"` first.
  - You should not run `terraform apply` locally unless explicitly requested.

## Module usage

- Prefer using modules from the terraform registry over local modules. The registry modules should be sourced from `miljodir` if available, e.g.

```hcl
module "sql" {
    source  = "miljodir/sql-server/azurerm"
    version = "~> 1.0"
    ...
}
```
- Available modules from miljodir are:
  - miljodir/virtual-network
  - miljodir/sql-server
  - miljodir/storage-account
  - miljodir/key-vault
  - miljodir/app-service
  - miljodir/function-app
  - miljodir/virtual-machine

- Use default values from the module, do not specify more optional values than required
- If a miljodir module is not available from the registry, prefer using the [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/), e.g.

```hcl
module "postgres" {
source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
version = "~> 0.1"
    ...
}
```

- The repo will have the `shared` module available for use, which contains common variables and outputs. Use this module where relevant.

## Security

- Resources use private endpoints unless otherwise specified.
  - When using modules, presume that the private endpoints are created within the module.
  - Public access should only be allowed in dev environments unless explicitly requested.
- Resources in the platform/dev folder may have public access enabled.
- Resources should use managed identity enabled where possible
- Storage accounts should have hierarchical namespace (HNS/datalake) disabled unless otherwise specified
- Azure key vaults uses RBAC for access control, and should not use access policies
  - The best secret is one that does not need to be stored. e.g. use Managed Identities with role assignments rather than passwords or keys.
  - If child resources for key vaults are created, they should be generated using the `azure/azapi` Terraform provider

## Documentation, variables and outputs

- Github Actions automatically generates documentation for Terraform files using `terraform-docs`. You may edit the docs if relevant, but leave the content within `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` untouched.

- Always include `description` and `type` attributes for variables and outputs unless otherwise specified.
  - Use clear and concise descriptions to explain the purpose of each variable and output.
  - Use appropriate types for variables (e.g., `string`, `number`, `bool`, `list`, `map`).
  - In complex types, use default values for properties where appropriate to simplify usage.

## Testing

- Agents may write temporarily tests if relevant, but we do not want them stored in the repository.
