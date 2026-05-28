variable "region" {
  description = "Main region"
  type        = string
  default     = "eu-north-1"
}

variable "zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "backend-server"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Key Pair name"
  type        = string
  default     = "key-pair"
}
