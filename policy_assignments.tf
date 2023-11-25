data "aws_iam_policy" "custom_policies" {
  for_each = { for key, value in try(var.custom_policies_map, []) : value => value }
  name     = each.value
}

data "aws_iam_policy" "boundary_policies" {
  for_each = { for key, value in try(var.boundary_policies_map, []) : value => value }
  name     = each.value
}

locals {
  group_managed_policy_attachments = flatten([
    for role in try(local.groups_permission_sets, []) : [
      for policy in try(var.managed_policies_map[role.permission] , []) : {
        permission_set = aws_ssoadmin_permission_set.groups_permission_sets["${role.groupname}-${role.permission}"]
        name           = policy
        arn            = "arn:aws:iam::aws:policy/${policy}"
      }]])

  group_custom_policy_attachments = flatten([
    for role in try(local.groups_permission_sets, []) : {
        permission_set = aws_ssoadmin_permission_set.groups_permission_sets["${role.groupname}-${role.permission}"]
        name           = var.custom_policies_map[role.permission]
      }
    if try(var.custom_policies_map[role.permission], []) != []
  ])
  
  group_boundary_policy_attachments = flatten([
    for role in try(local.groups_permission_sets, []) : {
        permission_set = aws_ssoadmin_permission_set.groups_permission_sets["${role.groupname}-${role.permission}"]
        name           = var.boundary_policies_map[role.permission]
      }
    if try(var.boundary_policies_map[role.permission], []) != []  
  ])
  
  users_managed_policy_attachments = flatten([
    for role in try(local.users_permission_sets, []) : [
      for policy in try(var.managed_policies_map[role.permission] , []) : {
        permission_set = aws_ssoadmin_permission_set.users_permission_sets["${role.username}-${role.permission}"]
        name           = policy
        arn            = "arn:aws:iam::aws:policy/${policy}"
      }]])

  users_custom_policy_attachments = flatten([
    for role in try(local.users_permission_sets, []) : {
        permission_set = aws_ssoadmin_permission_set.users_permission_sets["${role.username}-${role.permission}"]
        name           = var.custom_policies_map[role.permission]
      }
    if try(var.custom_policies_map[role.permission], []) != []
  ])
  
  users_boundary_policy_attachments = flatten([
    for role in try(local.users_permission_sets, []) : {
        permission_set = aws_ssoadmin_permission_set.users_permission_sets["${role.username}-${role.permission}"]
        name           = var.boundary_policies_map[role.permission]
      }
    if try(var.boundary_policies_map[role.permission], []) != []  
  ])
}

resource "aws_ssoadmin_managed_policy_attachment" "group_managed_policy_attachments" {
  for_each = { for policy in local.group_managed_policy_attachments : "${policy.permission_set.name}-${policy.name}" => policy }

  instance_arn       = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  permission_set_arn = each.value.permission_set.arn
  managed_policy_arn = each.value.arn

  depends_on         = [
    aws_ssoadmin_permission_set.groups_permission_sets,
  ]
} 

resource "aws_ssoadmin_customer_managed_policy_attachment" "group_custom_policy_attachments" {
  for_each = { for policy in local.group_custom_policy_attachments : "${policy.permission_set.name}-${policy.name}" => policy }

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  permission_set_arn = each.value.permission_set.arn
  customer_managed_policy_reference {
    name             = data.aws_iam_policy.custom_policies[each.value.name].name
  }

  depends_on         = [
    aws_ssoadmin_permission_set.groups_permission_sets,
  ]
}

resource "aws_ssoadmin_permissions_boundary_attachment" "group_boundary_policy_attachment" {
  for_each = { for policy in local.group_boundary_policy_attachments : "${policy.permission_set.name}-${policy.name}" => policy }

  instance_arn       = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  permission_set_arn = each.value.permission_set.arn
  permissions_boundary {
    customer_managed_policy_reference {
      name           = data.aws_iam_policy.boundary_policies[each.value.name].name
    }
  }

  depends_on         = [
    aws_ssoadmin_permission_set.groups_permission_sets,
  ]
}

resource "aws_ssoadmin_managed_policy_attachment" "users_managed_policy_attachments" {
  for_each = { for policy in local.users_managed_policy_attachments : "${policy.permission_set.name}-${policy.name}" => policy }

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  permission_set_arn = each.value.permission_set.arn
  managed_policy_arn = each.value.arn

  depends_on         = [ 
    aws_ssoadmin_permission_set.users_permission_sets,
  ]
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "users_custom_policy_attachments" {
  for_each = { for policy in local.users_custom_policy_attachments : "${policy.permission_set.name}-${policy.name}" => policy }

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  permission_set_arn = each.value.permission_set.arn
  customer_managed_policy_reference {
    name             = data.aws_iam_policy.custom_policies[each.value.name].name
  }

  depends_on         = [ 
    aws_ssoadmin_permission_set.users_permission_sets,
  ]
}

resource "aws_ssoadmin_permissions_boundary_attachment" "users_boundary_policy_attachment" {
  for_each = { for policy in local.users_boundary_policy_attachments : "${policy.permission_set.name}-${policy.name}" => policy }

  instance_arn       = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  permission_set_arn = each.value.permission_set.arn
  permissions_boundary {
    customer_managed_policy_reference {
      name           = data.aws_iam_policy.boundary_policies[each.value.name].name
    }
  }

  depends_on         = [ 
    aws_ssoadmin_permission_set.users_permission_sets,
  ]
}

resource "aws_ssoadmin_permission_set_inline_policy" "users_set_inline_policy" {
  for_each = { for permission_set in local.users_inline_permission_sets : "${permission_set.username}-${permission_set.account}" => permission_set }

  instance_arn = tolist(data.aws_ssoadmin_instances.instance.arns)[0]

  permission_set_arn = aws_ssoadmin_permission_set.users_inline_permission_sets[each.key].arn
  inline_policy      = jsonencode({
                         Version = "2012-10-17"
                         Statement = each.value.statements
                       })
  
  depends_on         = [
    aws_ssoadmin_permission_set.users_inline_permission_sets,
  ]
}