variable "email_domain" {
  type = string
}

variable "alias_to_id_map" {
  type = map(string)
}

variable "managed_policies_map" {
  type = map(list(string))
}

variable "custom_policies_map" {
  type = map(string)
}

variable "boundary_policies_map" {
  type = map(string)
}

variable "administrators_group" {
  type = string
}

variable "cli_roles_map" {
  type = map(list(string))
}

variable "users_data" {
  type = any
}

variable "groups_data" {
  type = any
}

variable "console_duration" {
  type    = string
  default = "PT12H"
}

variable "cli_duration" {
  type    = string
  default = "PT12H"
}

variable "cli_config" {
  type    = bool
  default = true
}