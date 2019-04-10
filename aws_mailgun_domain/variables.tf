variable "mail_domain" {
  description = "Domain which you want to use for sending/receiving email (e.g. `\"example.com\"`)"
}

variable "smtp_password" {
  description = "Password that Mailgun will require for sending out SMPT mail via this domain"
}

variable "spam_action" {
  description = "See https://www.terraform.io/docs/providers/mailgun/r/domain.html#spam_action"
  default     = "disabled"
}

variable "wildcard" {
  description = "See https://www.terraform.io/docs/providers/mailgun/r/domain.html#wildcard"
  default     = false
}

variable "tags" {
  description = "AWS Tags to add to all resources created (where possible); see https://aws.amazon.com/answers/account-management/aws-tagging-strategies/"
  type        = "map"
  default     = {}
}
