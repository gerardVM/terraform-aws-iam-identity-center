locals {
  users_data  = yamldecode(file(var.users_data_file))
  groups_data = yamldecode(file(var.groups_data_file))

  memberships = flatten ([
    for user_key, user_value in try(local.users_data, []) : [
      for group in try(user_value.groups, []) : {
        username  = user_key
        groupname = group
      }
    ]
  ])
}

resource "aws_identitystore_user" "users" {
  for_each = try(local.users_data, {})

  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name = each.key
  user_name    = "${each.key}@${var.email_domain}"

  name {
    given_name  = title(split(".", each.key)[0])
    family_name = try(title(split(".", each.key)[1]), title(split(".", var.email_domain)[0]))
  }

  emails {
    primary = true
    type    = "work"
    value   = "${each.key}@${var.email_domain}"
  }
}

resource "aws_identitystore_group" "groups" {
  for_each = try(local.groups_data, {})

  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name      = each.key
}

resource "aws_identitystore_group_membership" "memberships" {
  for_each = { for membership in local.memberships : "${membership.username}-${membership.groupname}" => membership }

  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  group_id = aws_identitystore_group.groups[each.value.groupname].group_id
  member_id = aws_identitystore_user.users[each.value.username].user_id
}