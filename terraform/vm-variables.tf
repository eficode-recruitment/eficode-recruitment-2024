variable "gce_vm_type" {
  description = "The type of the VM to create"
}

variable "gce_ssh_user" {
  description = "The SSH username to create on the VM"
  type        = string
}
variable "gce_ssh_user_eficode" {
  description = "The SSH username to create on the VM"
  type        = string
}

variable "gce_ssh_pub_key" {
  description = "The SSH public key to add to the VM"
  type        = string
}
variable "gce_ssh_pub_key_eficode" {
  description = "The SSH public key to add to the VM"
  type        = string
}
