resource "azurerm_resource_group" "this" {
  name     = "rg-${var.appName}"
  location = var.location
  tags = {
    environment = var.environment
    createdby   = var.createdby  
  }
}

resource "azurerm_storage_account" "this" {
  name                              = "sa${var.appName}"
  resource_group_name               = azurerm_resource_group.this.name
  location                          = azurerm_resource_group.this.location
  account_kind                      = "StorageV2"
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  cross_tenant_replication_enabled  = true
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = true
  shared_access_key_enabled         = true
  public_network_access_enabled     = true
  default_to_oauth_authentication   = false
  is_hns_enabled                    = false
  nfsv3_enabled                     = false
  
  tags = {
    environment = var.environment
    createdby   = var.createdby  
  }
}
