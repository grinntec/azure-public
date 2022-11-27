`bootstrap-terraform-azure`

# Overview
This tool will create the following resources that are needed to host Terraform state files and also access Azure with a service principal when executing Terraform code.

1. Resource group
2. A `canNotDelete` resource group lock
3. Storage account
4. Blob container
5. Key vault
6. Service principal, with credentials saved to the key vault

## tl:dr
> First edit the `the-environment.env` file with the specific variable values

> Then run the `runme.ps1`file

# How to use this tool
There are three files. The first is this file you are reading `readme.md` which you do not need to change. The second file `runme.ps1` is a PowerShell script that is the file you will execute to build the resources which you do not need to change. The last file is `the-environment.env` which holds the variable values used to create the resources, you will edit this file.

## Setting environment variables
Edit the file `the-environment.env` and enter data specific to your environment. These values are puled into the process and used to generate resource names or specific the target subscription.

**Edit these values**
|name|value
| ---|---
|ref|the name of project or app but no special characters
|az_region|the region where resources will be created
|az_sub_id|the subscription id
|az_tenant_id|the tenant id
|tag1|this is the environment tag; prod, dev or stage
|tag2|this is the createdby tag; 

**Edit these if you want but not required**
|name|value|description
|---|---|---
|rg_name|rg-tfstate-|the prefix to the resource group name
|sa_name|sastate|the prefix to the storage account name
|sa_con_name|satfstate|the name of the blob container
|kv_name|kvtfstate|the prefix to the key vault name
|sp_name|sp-terraform-|the prefix to the service principal name

For example, if your reference value was `faxe` then the created resources would be as follows

`rg-tfstate-faxe`

`sastatefaxe`

`satfstatefaxe`

`kvtfstatefaxe`

`sp-terraform-faxe`


# Run the tool
With the environment variables defined you just need to run the `runme.ps1` to build them. This uses Azure PowerShell CLI commands for the whole process, including the initial Azure log in to Azure and setting the subscription context based on the subscription you defined in the environment variables.

**Steps**
The `runme.ps1` script is built using two functions; `Set-ConfigVars` and `main`. Each function performs specific tasks to either prepare the variable values or execute the Azure PowerShell CLI commands. When the script is run the `main` function is called.

> Set-ConfigVars

This imports the `the-environment.env` file contents and strips out any row starting with # which are comments. It then takes each row value and maps to a key:value pair which are stored in a variable called `$values`

> main

This reads the `the-environment.env` file to define the parameter values. Then you are prompted to logon to the Azure subscription you defined. Then the resources are created in order.

> 

# File & folder structure
```shell
root
|   readme.md
|   runme.ps1
|   the-environment.env
```
# References
https://www.mytechramblings.com/posts/how-to-bootstrap-terraform-and-azdo-to-start-deploying-iac-to-azure/
https://github.com/karlospn/bootstrapping-azure-subscription-and-azdo-project-for-terraform
