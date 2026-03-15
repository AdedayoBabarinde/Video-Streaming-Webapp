output "frontdoor_id" {
  description = "Resource ID of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.afd.id
}

output "frontdoor_endpoint_hostname" {
  description = "Default AFD hostname (*.azurefd.net) — use for GoDaddy CNAME validation"
  value       = azurerm_cdn_frontdoor_endpoint.app.host_name
}

output "apex_domain_validation_token" {
  description = "TXT record value required by GoDaddy to validate the apex custom domain with AFD"
  value       = azurerm_cdn_frontdoor_custom_domain.apex.validation_token
}

output "www_domain_validation_token" {
  description = "TXT record value required by GoDaddy to validate the www custom domain with AFD"
  value       = azurerm_cdn_frontdoor_custom_domain.www.validation_token
}

output "waf_policy_id" {
  description = "Resource ID of the WAF policy attached to the Front Door profile"
  value       = azurerm_cdn_frontdoor_firewall_policy.waf.id
}
