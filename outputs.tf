output "cli_users" {
  value = local.cli_users
}

output "cli_profiles" {
  value = local.config_profiles
}

output "role_delegation_account_assignments" {
  value = try(aws_ssoadmin_account_assignment.role_delegation_account_assignments, {})
}

output "role_delegation_permission_sets" {
  value = try(aws_ssoadmin_permission_set.role_delegation_permission_sets, {})
}
