locals {
  groups_permission_sets = flatten([
    for group_key, group_value in try(var.groups_data, []) : [
      for permission_key, permission_value in try(group_value, []) : {
        groupname  = group_key
        permission = permission_key
        duration   = try(permission_value.duration, var.console_duration)
        accounts   = contains(permission_value.accounts, "all") ? keys(var.alias_to_id_map) : permission_value.accounts
      }]])
  
  users_permission_sets = flatten([
    for user_key, user_value in try(var.users_data, []) : [
      for permission_key, permission_value in try(user_value.permissions, []) : {
        username   = user_key
        permission = permission_key
        duration   = try(permission_value.duration, var.console_duration)
        accounts   = contains(permission_value.accounts, "all") ? keys(var.alias_to_id_map) : permission_value.accounts
      }]])
  
  users_inline_permission_sets = flatten([
    for user_key, user_value in try(var.users_data, []) : [
      for account_key, account_value in try(user_value.resources, []) : {
        username   = user_key
        principal  = aws_identitystore_user.users[user_key]
        account    = account_key
        account_id = var.alias_to_id_map[account_key]
        statements = account_value
        duration   = try(account_value.duration, var.console_duration)
      }]])
}

resource "aws_ssoadmin_permission_set" "groups_permission_sets" {
  for_each = { for permission_set in local.groups_permission_sets : "${permission_set.groupname}-${permission_set.permission}" => permission_set }

  name             = "${each.value.permission}@${each.value.groupname}"
  description      = "${each.value.permission} permissions"
  session_duration = "${each.value.duration}"
  instance_arn     = tolist(data.aws_ssoadmin_instances.instance.arns)[0]
}

resource "aws_ssoadmin_permission_set" "users_permission_sets" {
  for_each = { for permission_set in local.users_permission_sets : "${permission_set.username}-${permission_set.permission}" => permission_set }

  name             = "${replace(title(each.value.username), ".", "")}@${each.value.permission}"
  description      = "${each.value.permission} permissions"
  session_duration = "${each.value.duration}"
  instance_arn     = tolist(data.aws_ssoadmin_instances.instance.arns)[0]
}

resource "aws_ssoadmin_permission_set" "users_inline_permission_sets" {
  for_each = { for permission_set in local.users_inline_permission_sets : "${permission_set.username}-${permission_set.account}" => permission_set }

  name             = "${replace(title(each.value.username), ".", "")}@${each.value.account}"
  description      = "Permissions to specific resources"
  session_duration = "${each.value.duration}"
  instance_arn     = tolist(data.aws_ssoadmin_instances.instance.arns)[0]
}