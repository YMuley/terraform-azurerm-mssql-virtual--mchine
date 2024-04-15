locals {
  msslq_vm = {for sql in var.mssql_vm_list : sql.virtual_machine_name => sql}
}