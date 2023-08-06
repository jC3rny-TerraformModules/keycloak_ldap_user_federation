
terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.3.1"
    }
  }

  required_version = "~> 1.5.0"
}
