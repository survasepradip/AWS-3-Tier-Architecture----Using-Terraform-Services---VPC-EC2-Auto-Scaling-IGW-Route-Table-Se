
variable "vpc_cidr" {
  type        = string
  description = "The value for the vpc cidr"
}

variable "component" {
  type        = string
  description = "Name of the project we are working on"
  default     = "3-tier-architecture"
}

variable "public_subnetcidr" {
  type        = list(any)
  description = "(optional) describe your variable"
}

variable "private_subnetcidr" {
  type        = list(any)
  description = "(optional) describe your variable"
}

variable "database_subnetcidr" {
  type        = list(any)
  description = "(optional) describe your variable"
}

variable "instance_type" {
  type        = string
  description = "Instance type for ecs instances"
}

################################################################################
# CREATING MYSQL DATABASE VARIABLES
################################################################################

variable "db_name" {
  type        = string
  description = "(optional) describe your variable"
  default     = "webappdb" # MUST HAVE THIS NAME
}

variable "instance_class" {
  type        = string
  description = "(optional) describe your variable"
}

variable "username" {
  type        = string
  description = "(optional) describe your variable"
}

variable "port" {
  type        = number
  description = "(optional) describe your variable"
  default     = 3306
}

variable "dns_name" {
  description = "This is the dns name of that would be used to connect to all applications"
  type        = string

}

variable "subject_alternative_names" {
  type = list(any)
}

