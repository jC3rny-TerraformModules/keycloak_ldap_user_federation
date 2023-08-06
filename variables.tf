
# keycloak_realm
variable "keycloak_realm_name" {
  type = string
  #
  default = ""
}

# keycloak_ldap_user_federation
variable "keycloak_ldap_user_federation" {
  type = map(object({
    name     = optional(string)
    enabled  = optional(bool)
    priority = optional(number)
    #
    connection_url  = string
    bind_dn         = string
    bind_credential = string
    #
    edit_mode               = optional(string)
    users_dn                = string
    username_ldap_attribute = optional(string)
    rdn_ldap_attribute      = optional(string)
    uuid_ldap_attribute     = optional(string)
    user_object_classes     = optional(list(string))
    search_scope            = optional(string)
    #
    changed_sync_period = optional(number)
    full_sync_period    = optional(number)
    #
    trust_email = optional(bool)
    #
    attribute_mapper = optional(map(object({
      name = optional(string)
      #
      user_model_attribute = optional(string)
      ldap_attribute       = optional(string)
      #
      read_only                   = optional(bool)
      always_read_value_from_ldap = optional(bool)
      is_mandatory_in_ldap        = optional(bool)
    })))
  }))
}
