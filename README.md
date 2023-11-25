# AWS IAM IDENTITY CENTER

AWS IAM Identity Center is a Terraform module that creates a centralized identity management system in AWS.

Groups do not accept inline policy assignments

This module works when emails are like name.surname

You need to add "sso.amazonaws.com" to the resource.aws_organizations_organization.resource_name.aws_service_access_principals list in your Terraform configuration.