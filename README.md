# AWS IAM Identity Center Terraform Module

Terraform module which creates AWS IAM Identity Center resources on AWS using yaml files as input.

## Usage

### Implementation of the module

```hcl
module "iam_sso" {
  source = "github.com/gerardvm/terraform-aws-iam-identity-center?ref=1.1.0"

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

  users_data  = yamldecode(file("./users.yaml"))
  groups_data = yamldecode(file("./groups.yaml"))
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
  name:
    first: Name
    last: Surname1
  email: name.surname1@example.com
  cli-config: false
  groups:
    - Group2
name.surname2:
  email: name.surname2@example.com
  cli-config: false
  groups:
    - Group2
  permissions:
    AwsCosts:
      accounts:
        - account_alias_1
        - account_alias_2
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
  - **name.first:** (Optional) First name of the user.
  - **name.last:** (Optional) Last name of the user. Required if user definition does not include a name in the shape of name.surname.
  - **email:** (Required) Email of the user.
  - **cli-config:** (Optional) A boolean value indicating if the user should have a unique permission set focused on CLI, recommended for AWS CLI usage. The default value is true.
  - **groups:** (Optional) List of groups to which the user should be added.
  - **permissions:** (Optional) Map of permissions and accounts to which the user should have access to. The accounts are defined as a list of account aliases.
  - **resources:** (Optional) Map of accounts and resources to which the user should have access to. The resources are defined as a list of actions and resources. The actions and resources are defined as a list of strings.
- **For groups:**
  - Map of permissions and accounts to which the group should have access to. The accounts are defined as a list of account aliases.
- **Duration:** (Optional) Duration of the role session. The default value is PT12H. Format is ISO 8601 duration. Applicable for permissions and resources options.


## Notes

- **AWS Service Access Principals:** Ensure to include "sso.amazonaws.com" within the aws_service_access_principals list in your Terraform configuration for the aws_organizations_organization resource.

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.