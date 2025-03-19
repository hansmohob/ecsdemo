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
variable "PublicIPAddress" {
  description = "Public IP address (with /32 CIDR) for direct access to sample web application."
  type        = string
}
variable "NatGatewayAddress" {
  type        = string
  description = "NAT Gateway public IPs (with /32) for code-server outbound traffic - required for load testing from code-server instance."
}
variable "ImageTag" {
  description = "Amazon ECR sample application Image Tag"
  type        = string
  default     = "latest"
}