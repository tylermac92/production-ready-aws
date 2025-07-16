variable "env" { 
    type = string 
}

variable "vpc_id" { 
    type = string 
}

variable "private_subnet_ids" { 
    type = list(string) 
}

variable "db_name" { 
    type    = string 
    default = "appdb" 
}

variable "db_username" { 
    type    = string 
    default = "app_user" 
}

variable "instance_class" { 
    type    = string 
    default = "db.t4g.micro" 
}

variable "storage_gb" { 
    type    = number 
    default = 20 
}

variable "backup_retention" { 
    type    = number 
    default = 1 
}

variable "app_security_group_id" {
    type = string
}
