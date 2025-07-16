variable "env" { 
    description = "Environment (dev/prod)"   
    type        = string 
}

variable "vpc_id" { 
    description = "VPC ID"                   
    type        = string 
}

variable "public_subnet_ids" { 
    description = "Public Subnet IDs"        
    type        = list(string) 
}

variable "app_port" { 
    description = "Port your app listens on" 
    type        = number 
    default     = 80 
}