
locals {
  keycloak_ldap_user_federation = {
    for k, v in var.keycloak_ldap_user_federation : k => {
      name     = coalesce(v.name, k)
      enabled  = coalesce(v.enabled, true)
      priority = coalesce(v.priority, 0)
      #
      connection_url  = v.connection_url
      bind_dn         = v.bind_dn
      bind_credential = v.bind_credential
      #
      edit_mode               = coalesce(v.edit_mode, "READ_ONLY")
      users_dn                = v.users_dn
      username_ldap_attribute = coalesce(v.username_ldap_attribute, "uid")
      rdn_ldap_attribute      = coalesce(v.rdn_ldap_attribute, "uid")
      uuid_ldap_attribute     = coalesce(v.uuid_ldap_attribute, "entryUUID")
      #
      user_object_classes = coalesce(v.user_object_classes, [
        "inetOrgPerson",
        "organizationalPerson",
      ])
      search_scope = coalesce(v.search_scope, "SUBTREE")
      #
      changed_sync_period = coalesce(v.changed_sync_period, 21600)
      full_sync_period    = coalesce(v.full_sync_period, 604800)
      #
      trust_email = coalesce(v.trust_email, true)
      #
      attribute_mapper = try(v.attribute_mapper, null)
    }
  }
  #
  keycloak_ldap_user_attribute_mapper_aux = {
    for k, v in local.keycloak_ldap_user_federation : k => {
      for x, y in try(v.attribute_mapper, {}) : x => merge(y, {
        id                        = x
        ldap_user_federation_name = k
      })
    }
  }
  #
  keycloak_ldap_user_attribute_mapper = { for k, v in flatten([for obj in local.keycloak_ldap_user_attribute_mapper_aux : [for attr in obj : attr]]) : format("%s-%s", v.ldap_user_federation_name, v.id) => v }
}


data "keycloak_realm" "this" {
  realm = var.keycloak_realm_name
}


resource "keycloak_ldap_user_federation" "directory" {
  for_each = local.keycloak_ldap_user_federation
  #
  realm_id = data.keycloak_realm.this.id
  #
  name     = each.value.name
  priority = each.value.priority
  enabled  = each.value.enabled
  #
  connection_url  = each.value.connection_url
  bind_dn         = each.value.bind_dn
  bind_credential = each.value.bind_credential
  #
  edit_mode               = each.value.edit_mode
  users_dn                = each.value.users_dn
  username_ldap_attribute = each.value.username_ldap_attribute
  rdn_ldap_attribute      = each.value.rdn_ldap_attribute
  uuid_ldap_attribute     = each.value.uuid_ldap_attribute
  user_object_classes     = each.value.user_object_classes
  search_scope            = each.value.search_scope
  #
  changed_sync_period = each.value.changed_sync_period
  full_sync_period    = each.value.full_sync_period
  #
  trust_email = each.value.trust_email
  #
  depends_on = [
    data.keycloak_realm.this
  ]
}

resource "keycloak_ldap_user_attribute_mapper" "attribute" {
  for_each = local.keycloak_ldap_user_attribute_mapper
  #
  realm_id                = data.keycloak_realm.this.id
  ldap_user_federation_id = keycloak_ldap_user_federation.directory[each.value.ldap_user_federation_name].id
  #
  name = coalesce(each.value.name, each.value.id)
  #
  user_model_attribute = each.value.user_model_attribute
  ldap_attribute       = each.value.ldap_attribute
  #
  read_only                   = coalesce(each.value.read_only, true)
  always_read_value_from_ldap = coalesce(each.value.always_read_value_from_ldap, true)
  is_mandatory_in_ldap        = coalesce(each.value.is_mandatory_in_ldap, true)
  #
  depends_on = [
    data.keycloak_realm.this,
    keycloak_ldap_user_federation.directory
  ]
}
