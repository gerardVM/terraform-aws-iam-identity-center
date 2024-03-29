module "iam_sso" {
  source = "github.com/gerardvm/terraform-aws-iam-identity-center?ref=2.1.0"

  alias_to_id_map = {
    "management_account" = "123456789012"
    "account_alias_2"    = "account_id_2"
    "account_alias_3"    = "account_id_3"
  }

  managed_policies_map = {
    "Administrator" = ["AdministratorAccess"]
    "Business"      = ["ReadOnlyAccess","AmazonRoute53DomainsFullAccess"]
    "Developer"     = ["IAMReadOnlyAccess","PowerUserAccess"]
    "Billing"       = ["AWSBillingReadOnlyAccess"]
    "ReadOnly"      = ["ReadOnlyAccess"]
  }

  custom_policies_map = {
    "AwsCosts"      = "custom-aws-costs"
    "Business"      = "custom-business"
    "Developer"     = "custom-developer"
  }

  boundary_policies_map = {}

  # cli settings

  administrators_group  = "Group1"

  cli_roles_map = {
    "Administrator" = ["CLIAdministrator"] 
    "AwsCosts"      = ["CLIAwsCosts"]
    "Business"      = ["CLIBusiness"]
    "Developer"     = ["CLIDeveloper"]
    "Billing"       = ["CLIFinance"]
    "ReadOnly"      = ["CLIReadOnly"]
  }

  # Config files

  users_data  = yamldecode(file("./example_users.yaml"))
  groups_data = yamldecode(file("./example_groups.yaml"))
}


# Creation of the config file

resource "local_file" "config_file" {
  for_each = try(module.iam_sso.cli_users, {})

  filename = "${path.root}/cli_users/${each.key}/config"
  content  = templatefile("./templates/config.tftpl", {
    sso_start_url  = "https://example.awsapps.com/start" # Available in the AWS IAM Identity Center console
    sso_account_id = module.iam_sso.role_delegation_account_assignments[each.key].target_id
    sso_region     = "us-east-1"
    sso_role_name  = module.iam_sso.role_delegation_permission_sets[each.key].name
    profiles       = module.iam_sso.cli_profiles[each.key]
  })
}