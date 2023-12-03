locals {
  cli_users = { for user_name, user_value in try(local.users_data, []) : user_name => user_value if try(user_value.cli-config, var.cli_config) }

  individual_assumed_roles = { for user_name, user_value in try(local.users_data, []) : user_name => flatten([
    for permission_key, permission_value in try(user_value.permissions,[]) : [
      for account in contains(permission_value.accounts, "all") ? keys(var.alias_to_id_map) : permission_value.accounts : [
        for role in var.cli_roles_map[permission_key] : "arn:aws:iam::${var.alias_to_id_map[account]}:role/${role}"
      ]
    ]
  ])}

  group_assumed_roles = { for group_name, group_value in try(local.groups_data, []) : group_name => flatten([
    for permission_key, permission_value in group_value : [
      for account in contains(permission_value.accounts, "all") ? keys(var.alias_to_id_map) : permission_value.accounts : [
        for role in var.cli_roles_map[permission_key] : "arn:aws:iam::${var.alias_to_id_map[account]}:role/${role}"
      ]
    ]
  ])}

  individual_resources_metaroles = { for user_name, user_value in try(local.users_data, []) : user_name => flatten([
    for account_key, account_value in try(user_value.resources, []) : "arn:aws:iam::${var.alias_to_id_map[account_key]}:role/${replace(title(user_name), ".", "")}CustomResources"
  ])}

  user_role_list = {for user_name, user_value in try(local.users_data, []) : user_name => concat(
    local.individual_assumed_roles[user_name],
    flatten([ for group in try(user_value.groups, []) : local.group_assumed_roles[group] ]),
    local.individual_resources_metaroles[user_name]
  )}

  id_to_alias_map = { for k, v in var.alias_to_id_map : v => k if v != "" }

  config_profiles = { for user_name, user_value in try(local.users_data, []) : user_name => [
    for role in try(local.user_role_list[user_name], []) : {
      role_name     = split("/", role)[1]
      role_arn      = role
      account_alias = local.id_to_alias_map[split(":", role)[4]]
    }
  ]}
}

# Create a policy to assume all roles based on the user's permissions, ensuring that duplicate roles are removed.

data "aws_iam_policy_document" "role_delegation_user_policies" {
  for_each = try(local.cli_users, {})
  
  statement {
    sid       = "AllowAssumeRole"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = contains(try(each.value.groups, []), var.administrators_group) ? ["*"] : local.user_role_list[each.key]
  }
}

resource "aws_ssoadmin_permission_set" "role_delegation_permission_sets" {
  for_each = try(local.cli_users, {})

  name             = "${each.key}@cli"
  description      = "Permissions for AWS CLI"
  session_duration = try(each.value.cli_duration, var.cli_duration)
  instance_arn     = tolist(data.aws_ssoadmin_instances.instance.arns)[0]
}

resource "aws_ssoadmin_permission_set_inline_policy" "role_delegation_set_inline_policy" {
  for_each = try(local.cli_users, {})

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.role_delegation_permission_sets[each.key].arn
  inline_policy      = data.aws_iam_policy_document.role_delegation_user_policies[each.key].json
  
  depends_on         = [
    aws_ssoadmin_permission_set.role_delegation_permission_sets,
  ]
}

resource "aws_ssoadmin_account_assignment" "role_delegation_account_assignments" {
  for_each = try(local.cli_users, {})

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  target_id          = data.aws_caller_identity.current.account_id
  target_type        = "AWS_ACCOUNT"
  principal_id       = aws_identitystore_user.users[each.key].user_id
  principal_type     = "USER"
  permission_set_arn = aws_ssoadmin_permission_set.role_delegation_permission_sets[each.key].arn

  depends_on         = [
    aws_ssoadmin_permission_set_inline_policy.role_delegation_set_inline_policy,
  ]
}
