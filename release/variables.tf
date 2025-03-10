variable "PrefixCode" {
  description = "Prefix for resource names"
  type        = string
}
variable "EnvCode" {
  description = "Resource name environment variable"
  type        = string
}
variable "Region" {
  description = "AWS region for resource deployment"
  type        = string
}

variable "EnvTag" {
  description = "Environment identifier for resource tagging (e.g., dev, prod)"
  type        = string
}

variable "SolTag" {
  description = "Solution identifier for resource grouping and tagging"
  type        = string
}
variable "VpcCidr" {
  description = "The first two octets of the CIDR IP address range e.g. 10.0"
  type        = string
}
variable "Az01" {
  description = "Deployment Availability Zone 1 e.g. eu-west-1a"
  type        = string
}
variable "Az02" {
  description = "Deployment Availability Zone 2 e.g. eu-west-1b"
  type        = string
}
variable "PublicIP" {
  description = "The Public IP address from which the web application will be accessed e.g. x.x.x.x/32"
  type        = string
}
variable "ImageTag" {
  description = "Amazon ECR sample application Image Tag overridden by CodeBuild"
  type        = string
  default     = "latest"
}