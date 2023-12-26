# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0](https://github.com/gerardvm/terraform-aws-iam-identity-center/compare/1.1.0...2.0.0) (2023-12-26)

### ⚠ BREAKING CHANGES

* Name and email of users are now fields in the user configuration of user_data file (#2)


### Features

* Name and email of users are now a field in the user configuration of user_data file.

### Fix

* Fake tracking roles are not added in cli permissions policy anymore since its usecase was confusing.


## [1.1.0](https://github.com/gerardvm/terraform-aws-iam-identity-center/compare/1.0.0...1.1.0) (2023-12-3)


### ⚠ BREAKING CHANGES

* Many variables are now read automatically instead of having to be specified in the module. (#1)


### Features

* Module becomes clearer. Many variables are now read automatically instead of having to be specified in the module. (#1)


## [1.0.0](https://github.com/gerardvm/terraform-aws-iam-identity-center/compare/1.0.0...1.1.0) (2023-11-25)


### Features

* First commit. Module is working as expected.
