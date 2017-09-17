variable "name" {
  type        = "string"
  description = "The name of infrastructure stack, e.g. 'rocket'"
}

variable "environment" {
  type        = "string"
  description = "The name of the environment, e.g. 'staging'"
}

variable "zones" {
  type        = "list"
  description = "Availability Zones"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "region" {
  type        = "string"
  description = "AWS Region Used"
  default     = "ap-southeast-1"
}

variable "profile" {
  type        = "string"
  description = "AWS Profile used"
  default     = "default"
}

variable "vpc_cidr" {
  type        = "string"
  description = "VPC CIDR range"
  default     = "10.22.0.0/16"
}

variable "external_subnets" {
  type        = "list"
  description = "The external subnets, need to match the AZs"
  default     = ["10.22.0.0/22", "10.22.32.0/22"]
}

variable "internal_subnets" {
  type        = "list"
  description = "The internal subnets, need to match the AZs"
  default     = ["10.22.64.0/18", "10.22.128.0/18"]
}

variable "internal_db_subnets" {
  type        = "list"
  description = "The internal subnets for DB"
  default     = ["10.22.192.0/19", "10.22.224.0/19"]
}

variable "key_file" {
  type        = "string"
  description = "SSH Public Key"
}

variable "bastion_instance_type" {
  type        = "string"
  description = "Type of bastion host for tunneling"
  default     = "t2.nano"
}

variable "ecs_base_cluster_name" {
  type        = "string"
  description = "The base name of the ECS Cluster"
}

variable "ecs_instance_type" {
  type        = "string"
  description = "The instance type of the ecs cluster instance"
  default     = "t2.medium"
}

variable "ecs_min_size" {
  description = "The minimum size of the cluster"
  type        = "string"
  default     = "1"
}

variable "ecs_max_size" {
  description = "The maximum size of the cluster"
  type        = "string"
  default     = "99"
}

variable "ecs_desired_capacity" {
  description = "The desired capacity of the cluster"
  type        = "string"
  default     = "3"
}

variable "ecs_root_volume_size" {
  description = "The size of the instance root volume"
  default     = "25"
  type        = "string"
}

variable "ecs_docker_volume_size" {
  description = "The size of the ecs instance docker volume"
  default     = "25"
  type        = "string"
}
