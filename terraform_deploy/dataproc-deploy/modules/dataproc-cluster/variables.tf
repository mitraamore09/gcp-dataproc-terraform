variable "dataproc_master_machine_type" {
  type        = string
  description = "dataproc master node machine tyoe"
  default     = "e2-standard-2"
}

variable "dataproc_worker_machine_type" {
  type        = string
  description = "dataproc worker nodes machine type"
  default     = "e2-standard-2"
}
variable "dataproc_master_count" {
  type        = number
  description = "count of master nodes in cluster"
  default     = 1
}
variable "dataproc_workers_count" {
  type        = number
  description = "count of worker nodes in cluster"
  default     = 2
}
variable "dataproc_master_bootdisk" {
  type        = number
  description = "primary disk attached to master node, specified in GB"
  default     = 50
}

variable "dataproc_worker_bootdisk" {
  type        = number
  description = "primary disk attached to master node, specified in GB"
  default     = 50
}

variable "worker_local_ssd" {
  type        = number
  description = "primary disk attached to master node, specified in GB"
  default     = 0
}

variable "preemptible_worker" {
  type        = number
  description = "number of preemptible nodes to create"
  default     = 0
}
variable "prefix" {
  type        = string
  description = "ID of the Google Project"
}
variable "region" {
  type        = string
  description = "Default Region"
}

variable "subnet_id" {
  type = string
  description = "subnet id for cluster"
}

variable "project_id"{
  type = string
  description = "project id"
}