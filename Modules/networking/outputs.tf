output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "aks_system_subnet_id" {
  description = "Subnet ID for the system node pool (zone 1)"
  value       = azurerm_subnet.aks_system.id
}

output "aks_app_subnet_id" {
  description = "Subnet ID for the app node pool (zone 2)"
  value       = azurerm_subnet.aks_app.id
}

output "ingress_subnet_id" {
  description = "Subnet ID for the ingress controller"
  value       = azurerm_subnet.ingress.id
}
