variable "alias_to_id_map" {
  type = map(string)
}

variable "managed_policies_map" {
  type = map(list(string))
  default = {}
}

variable "custom_policies_map" {
  type = map(string)
  default = {}
}

variable "boundary_policies_map" {
  type = map(string)
  default = {}
}

variable "administrators_group" {
  type = string
  default = ""
}

variable "cli_roles_map" {
  type = map(list(string))
  default = {}
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