variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where resources are to be deployed"
}

variable "alert_email_address" {
  type        = string
  description = "Email address where alert emails are sent"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix to use for resources that need to be created (only lowercase characters and hyphens allowed)"
  default     = "azure-app-example--"
}

variable "app_service_name" {
  type        = string
  description = "Name for the app service"
  default     = "appservice"
}

# https://www.terraform.io/docs/providers/azurerm/r/application_insights.html#application_type
variable "app_insights_app_type" {
  type        = string
  description = "The type of Application Insights to create."
  default     = "other"
}

# https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/
variable "app_service_plan_tier" {
  type        = string
  description = "App service plan's tier"
  default     = "PremiumV2"
}

variable "app_service_plan_size" {
  type        = string
  description = "App service plan's size"
  default     = "P1v2"
}

locals {
  cleansed_prefix = replace(var.name_prefix, "/[^a-zA-Z0-9]+/", "")
}
