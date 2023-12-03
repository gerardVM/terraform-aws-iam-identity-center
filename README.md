# AWS IAM Identity Center Terraform Module

Terraform module which creates AWS IAM Identity Center resources on AWS using yaml files as input.

## Usage

### Implementation of the module

```hcl
module "iam_sso" {
  source = "github.com/gerardvm/terraform-aws-iam-identity-center?ref=1.1.0"

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

  boundary_policies_map = {
    "Developer"     = "boundary-developer"
    "Billing"       = "boundary-billing"
  }

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

  users_data_file  = "./example_users.yaml"
  groups_data_file = "./example_groups.yaml"
}
```

### Example of users and groups yaml configuration files
<table>
<tr>
<th> users.yaml </th>
<th> groups.yaml </th>
</tr>
<tr>
<td>

```yaml
#Finance
name.surname1:
  cli-config: false
  groups:
    - Group2
name.surname2:
  cli-config: false
  groups:
    - Group2
  resources:
    account_alias_2:
      - Effect: Allow
        Resource:
          - "*"
        Action:
          - "s3:ListAllMyBuckets"
```

</td>
<td>

```yaml
Group1:
  Administrator:
    duration: PT12H
    accounts:
      - all

Group2:
  Billing:
    accounts:
      - account_alias_1

Group3:
  ReadOnly:
    accounts:
      - account_alias_1
      - account_alias_3
```


</td>
</tr>
</table>

## Yaml settings

- **For users:**
  - **cli-config:** (Optional) Boolean value to indicate if the user should have a CLI configuration file created. Default is true.
  - **groups:** (Optional) List of groups to which the user should be added.
  - **permissions:** (Optional) Map of permissions and accounts to which the user should have access to. The accounts are defined as a list of account aliases.
  - **resources:** (Optional) Map of accounts and resources to which the user should have access to. The resources are defined as a list of actions and resources. The actions and resources are defined as a list of strings.
- **For groups:**
  - **permissions:** (Required) Map of permissions and accounts to which the group should have access to. The accounts are defined as a list of account aliases.
- **Duration (Optional):** Duration of the role session. Default is PT12H. Format is ISO 8601 duration. Applicable for permissions and resources options.


## Notes

- **AWS Service Access Principals:** Ensure to include "sso.amazonaws.com" within the aws_service_access_principals list in your Terraform configuration for the aws_organizations_organization resource.

- **Email Format Requirement:** The module operates effectively when user emails follow the "name.surname" format.