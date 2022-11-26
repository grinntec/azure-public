`terraform-bootstrap-azure`

This tool will setup storage in the given Azure subscription that can be used to host Terraform state files for resources built in the subscription.

# tl:dr
> First edit the `the-environment.env` file with the specific variable values

> Then run the `runme.ps1`file

# How to use this tool
There are three files. The first is this file you are reading `readme.md` which you do not need to change. The second file `runme.ps1` is a PowerShell script that is the file you will execute to build the resources which you do not need to change. The last file is `the-environment.env` which holds the variable values used to create the resources, you will edit this file.

# Setting environment variables
Edit the file `the-environment.env` and enter data specific to your environment. These values are puled into the process and used to generate resource names or specific the target subscription.

**Edit these value**
|name|value
| ---|---
|ref|the name of project or app
|az_region|the region where resources will be created
|az_sub_id|the subscription id
|az_tenant_id|the tenant id

**Edit these if you want but not required**
|name|value
| ---|---
|rg_name|tfstate-
|sa_name|sastate
|sa_name|satfstate

# Run the tool
With the environment variables defined you just need to run the `runme.ps1` to build them. This uses Azure PowerShell CLI commands for the whole process, including the initial Azure log in to Azure and setting the subscription context based on the subscription you defined in the environment variables.

**Steps**
The `runme.ps1` script is built using functions. Each function performs specific tasks to either prepare the variable values or execute the Azure PowerShell CLI commands.

> function Set-ConfigVars

This imports the `the-environment.env` file contents and strips out any row starting with # which are comments. It then takes each row value and maps to a key:value pair which are stored in a variable called `$values`

> main
This reads the `the-environment.env` file to define the parameter values. Then you are prompted to logon to the Azure subscription you defined. Then the resource group, storage account, and blob container is created.

**File & folder structure**r
```shell
root
|   readme.md
|   runme.ps1
|   the-environment.env
```

https://www.mytechramblings.com/posts/how-to-bootstrap-terraform-and-azdo-to-start-deploying-iac-to-azure/
https://github.com/karlospn/bootstrapping-azure-subscription-and-azdo-project-for-terraform
