variable "role_name" {
  description = "Name of the IAM role"
}

variable "role_policy_json" {
  description = "Policy json as string type"
  type = string
}

variable "create_lambda_role" {
  description = "Whether to create the role or not"
}
