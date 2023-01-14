variable "region" {
  type        = string
  description = "AWS region to deploy into."
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block to use for the VPC.  Defaults to 10.0.0.0/16."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = list(any)
  description = "CIDR block to use for the VPC.  Defaults to 10.0.0.0/16."
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  type        = list(any)
  description = "CIDR block to use for the VPC.  Defaults to 10.0.0.0/16."
  default     = ["10.0.1.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "http_https_port" {
  type        = map(any)
  description = "http and https port"
  default = {
    http_port = {
      from_port = 80
      to_port   = 80
    }
    https_port = {
      from_port = 443
      to_port   = 443
    }
  }

}

variable "ami_id_for_windows" {
    default = "ami-0be29bafdaad782db"
  
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
    default = "Group"  
}

variable "rdp_ssh_port" {
  type        = map(any)
  description = "rdp and ssh port"
  default = {
    rdp_port = {
      from_port = 3389
      to_port   = 3389
    }
    https_port = {
      from_port = 22
      to_port   = 22
    }
  }

}

variable "bucket_prefix" {
    type = string
    default = "cloudwave-bucket"
  
}

variable "acl" {
    type        = string
    description = " Defaults to private "
    default     = "private"
}