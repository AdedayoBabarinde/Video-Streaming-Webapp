# ============================================================
# Azure Front Door Standard — CDN + WAF layer
# Sits in front of the Azure Standard LB that ingress-nginx
# exposes. TLS is terminated at the AFD edge (global PoPs);
# traffic is forwarded to the origin over HTTPS.
# ============================================================

resource "azurerm_cdn_frontdoor_profile" "afd" {
  name                = var.frontdoor_name
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}

# -------------------------------------------------------
# Endpoint — the AFD-assigned hostname
# -------------------------------------------------------
resource "azurerm_cdn_frontdoor_endpoint" "app" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
  tags                     = var.tags
}

# -------------------------------------------------------
# Origin Group — points to the AKS public LB IP
# -------------------------------------------------------
resource "azurerm_cdn_frontdoor_origin_group" "app" {
  name                     = "aks-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 2
    additional_latency_in_milliseconds = 0
  }

  health_probe {
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
    interval_in_seconds = 30
  }
}

resource "azurerm_cdn_frontdoor_origin" "aks_lb" {
  name                           = "aks-lb-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.app.id
  host_name                      = var.origin_host_name
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.apex_domain
  priority                       = 1
  weight                         = 1000
  enabled                        = true
  certificate_name_check_enabled = true
}

# -------------------------------------------------------
# Custom Domains — apex + www, AFD-managed TLS certs
# -------------------------------------------------------
resource "azurerm_cdn_frontdoor_custom_domain" "apex" {
  name                     = "apex-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
  host_name                = var.apex_domain

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "www" {
  name                     = "www-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
  host_name                = "www.${var.apex_domain}"

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

# -------------------------------------------------------
# Route — HTTPS-only forwarding, covers all paths
# -------------------------------------------------------
resource "azurerm_cdn_frontdoor_route" "app" {
  name                          = "app-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.app.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.app.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.aks_lb.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true

  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.apex.id,
    azurerm_cdn_frontdoor_custom_domain.www.id,
  ]
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "apex" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.apex.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.app.id]
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "www" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.www.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.app.id]
}

# -------------------------------------------------------
# WAF Policy — OWASP + Bot Manager managed rule sets
# -------------------------------------------------------
resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  name                = "${replace(var.frontdoor_name, "-", "")}waf"
  resource_group_name = var.resource_group_name
  sku_name            = azurerm_cdn_frontdoor_profile.afd.sku_name
  enabled             = true
  mode                = "Prevention"

  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_security_policy" "waf" {
  name                     = "waf-security-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.app.id
        }
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.apex.id
        }
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.www.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
