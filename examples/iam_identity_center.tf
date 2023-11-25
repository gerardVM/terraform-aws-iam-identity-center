module "iam_sso" {
  source = "github.com/gerardvm/terraform-aws-iam-identity-center?ref=1.0.0"

  email_domain = "example.com"

  alias_to_id_map = {
    "management_account" = "123456789012"
    "account_alias_2"    = "account_id_2"
    "account_alias_3"    = "account_id_3"
  }

  managed_policies_map = {
    "Administrator" = ["AdministratorAccess"] 
    "AwsCosts"      = []
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

  management_account_id = "123456789012"
  sso_start_url         = "https://example.awsapps.com/start" # Available in the AWS IAM Identity Center console
  sso_region            = "us-east-1"
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

  users_data_file  = "./example_users.yaml"
  groups_data_file = "./example_groups.yaml"
}