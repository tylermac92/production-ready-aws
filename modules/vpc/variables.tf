variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "name_prefix" {
    description = "Prefix for all resource names"
    type        = string
}