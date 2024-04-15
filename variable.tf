variable "mssql_vm_list" {
  type = list(any)
  default = []
  description = "configuration list of mssql vm"
}

variable "windows_vm_output" {
  type = map(any)
  default = {}
  description = "object list of windows vm"
} 