data "azurerm_client_config" "current" {
}
variable "domain" {}
variable "rg" {}

resource "null_resource" "b2c" {
  triggers = {
    subs   = data.azurerm_client_config.current.subscription_id
    rg     = var.rg
    domain = var.domain
  }
  provisioner "local-exec" {
    command = <<EOF
      export SUBS=${self.triggers.subs}
      export RG=${self.triggers.rg}
      export DOMAIN=${self.triggers.domain}
      az rest --method put --url https://management.azure.com/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.AzureActiveDirectory/b2cDirectories/$DOMAIN.onmicrosoft.com?api-version=2019-01-01-preview --body @b2c.json --verbose
    EOF
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      export SUBS=${self.triggers.subs}
      export RG=${self.triggers.rg}
      export DOMAIN=${self.triggers.domain}
      az rest --method delete --url https://management.azure.com/subscriptions/$SUBS/resourceGroups/$RG/providers/Microsoft.AzureActiveDirectory/b2cDirectories/$DOMAIN.onmicrosoft.com?api-version=2019-01-01-preview --verbose
    EOF
  }
}