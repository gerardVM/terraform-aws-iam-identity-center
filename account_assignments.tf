locals {
  group_account_assignments = flatten([
    for permission in try(local.groups_permission_sets, []) : [
      for account in try(permission.accounts, []) : {
        permission_set = aws_ssoadmin_permission_set.groups_permission_sets["${permission.groupname}-${permission.permission}"]
        account_id     = var.alias_to_id_map[account]
        principal      = aws_identitystore_group.groups[permission.groupname]
      }]])
  
  users_account_assignments = flatten([
    for permission in try(local.users_permission_sets, []) : [
      for account in try(permission.accounts, []) : {
        permission_set = aws_ssoadmin_permission_set.users_permission_sets["${permission.username}-${permission.permission}"]
        account_id     = var.alias_to_id_map[account]
        principal      = aws_identitystore_user.users[permission.username]
      }]])
}

resource "aws_ssoadmin_account_assignment" "group_account_assignments" {
  for_each = { for account in local.group_account_assignments : "${account.permission_set.name}-${account.account_id}" => account }

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
  principal_id       = each.value.principal.group_id
  principal_type     = "GROUP"
  permission_set_arn = each.value.permission_set.arn

  depends_on         = [
    aws_ssoadmin_managed_policy_attachment.group_managed_policy_attachments,
    aws_ssoadmin_customer_managed_policy_attachment.group_custom_policy_attachments,
    aws_ssoadmin_permissions_boundary_attachment.group_boundary_policy_attachment,
  ]
}

resource "aws_ssoadmin_account_assignment" "users_account_assignments" {
  for_each = { for account in local.users_account_assignments : "${account.permission_set.name}-${account.account_id}" => account }

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
  principal_id       = each.value.principal.user_id
  principal_type     = "USER"
  permission_set_arn = each.value.permission_set.arn

  depends_on         = [
    aws_ssoadmin_managed_policy_attachment.users_managed_policy_attachments,
    aws_ssoadmin_customer_managed_policy_attachment.users_custom_policy_attachments,
    aws_ssoadmin_permissions_boundary_attachment.users_boundary_policy_attachment,
  ]
}

resource "aws_ssoadmin_account_assignment" "users_inline_account_assignments" {
  for_each = { for permission_set in local.users_inline_permission_sets : "${permission_set.username}-${permission_set.account}" => permission_set }

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
  principal_id       = each.value.principal.user_id
  principal_type     = "USER"
  permission_set_arn = aws_ssoadmin_permission_set.users_inline_permission_sets[each.key].arn

  depends_on         = [
    aws_ssoadmin_permission_set_inline_policy.users_set_inline_policy,
  ]
}