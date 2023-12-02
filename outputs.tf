output "sso_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "cli_users" {
  value = try(local.cli_users, {})
}

output "sso_role_name" {
  value = try(aws_ssoadmin_permission_set.role_delegation_permission_sets)
}

output "cli_profiles" {
  value = try(local.config_profiles)
}
