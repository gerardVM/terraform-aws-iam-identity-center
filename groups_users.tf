locals {
  memberships = flatten ([
    for user_key, user_value in try(var.users_data, []) : [
      for group in try(user_value.groups, []) : {
        username  = user_key
        groupname = group
      }
    ]
  ])
}

resource "aws_identitystore_user" "users" {
  for_each = try(var.users_data, {})

  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name = each.key
  user_name    = each.key

  name {
    given_name  = try(each.value.name.first, title(split(".", each.key)[0]))
    family_name = try(each.value.name.last, title(split(".", each.key)[1]))
  }

  emails {
    primary = true
    type    = "work"
    value   = each.value.email
  }
}

resource "aws_identitystore_group" "groups" {
  for_each = try(var.groups_data, {})

  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name      = each.key
}

resource "aws_identitystore_group_membership" "memberships" {
  for_each = { for membership in local.memberships : "${membership.username}-${membership.groupname}" => membership }

  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  group_id = aws_identitystore_group.groups[each.value.groupname].group_id
  member_id = aws_identitystore_user.users[each.value.username].user_id
}