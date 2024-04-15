resource "azurerm_mssql_virtual_machine" "sql_server" {
    for_each                            = local.msslq_vm
    virtual_machine_id                  = var.windows_vm_output[each.value.virtual_machine_name].id
    sql_license_type                    = each.value.sql_license_type
    r_services_enabled                  = each.value.r_services_enabled
    sql_connectivity_port               = each.value.sql_connectivity_port
    sql_connectivity_type               = each.value.sql_connectivity_type
    sql_connectivity_update_password    = each.value.sql_connectivity_update_password
    sql_connectivity_update_username    = each.value.sql_connectivity_update_username
    sql_virtual_machine_group_id        = each.value.sql_virtual_machine_group_id == null ? null : each.value.sql_virtual_machine_group_id
    tags                                = each.value.tags
    dynamic "auto_patching" {
        for_each = each.value.auto_patching == [] ? [] : each.value.auto_patching
     content {
        day_of_week                             = auto_patching.value.day_of_week
        maintenance_window_duration_in_minutes  = auto_patching.value.maintenance_window_duration_in_minutes
        maintenance_window_starting_hour        = auto_patching.value.maintenance_window_starting_hour
    } 
    }

    dynamic "auto_backup" {
        for_each = each.value.auto_backup == [] ? [] : each.value.auto_backup
     content {
          encryption_enabled               = auto_backup.value.encryption_enabled
          encryption_password              = auto_backup.value.encryption_enabled != true ? [] : auto_backup.value.encryption_enabled 
          retention_period_in_days         = auto_backup.value.retention_period_in_days
          storage_blob_endpoint            = format("https://%s.blob.core.windows.net/",auto_backup.value.storage_blob_endpoint)
          storage_account_access_key       = auto_backup.value.storage_account_access_key
          system_databases_backup_enabled  = auto_backup.value.system_databases_backup_enabled
          dynamic "manual_schedule" {
            for_each = auto_backup.value.manual_schedule == [] ? [] : auto_backup.value.manual_schedule
            content {
              full_backup_frequency           = manual_schedule.value.full_backup_frequency
              full_backup_start_hour          = manual_schedule.value.full_backup_start_hour
              full_backup_window_in_hours     = manual_schedule.value.full_backup_window_in_hours
              log_backup_frequency_in_minutes = manual_schedule.value.log_backup_frequency_in_minutes
              days_of_week                    = manual_schedule.value.days_of_week
            }
          }
        }
      
    }

    dynamic "key_vault_credential" {
      for_each = each.value.key_vault_credential == [] ? [] : each.value.key_vault_credential
      content {
        name                      = key_vault_credential.value.name
        key_vault_url             = key_vault_credential.value.key_vault_url
        service_principal_name    = key_vault_credential.value.service_principal_name
        service_principal_secret  = key_vault_credential.value.service_principal_secretkk
      } 
    }

    dynamic "sql_instance" {
      for_each = each.value.sql_instance == [] ? [] : each.value.sql_instance
      content {
        adhoc_workloads_optimization_enabled = sql_instance.value.adhoc_workloads_optimization_enabled
        collation                            = sql_instance.value.collation
        instant_file_initialization_enabled  = sql_instance.value.instant_file_initialization_enabled
        lock_pages_in_memory_enabled         = sql_instance.value.lock_pages_in_memory_enabled
        max_dop                              = sql_instance.value.max_dop
        max_server_memory_mb                 = sql_instance.value.max_server_memory_mb
        min_server_memory_mb                 = sql_instance.value.min_server_memory_mb
      }
    }

    dynamic "storage_configuration" {
      for_each = each.value.storage_configuration == [] ? [] : each.value.storage_configuration
      content {
        disk_type             = storage_configuration.value.disk_type
        storage_workload_type = storage_configuration.value.storage_workload_type
       
        dynamic "data_settings" {
          for_each = storage_configuration.value.data_settings == [] ? [] : storage_configuration.value.data_settings
          content {
            default_file_path = data_settings.value.default_file_path
            luns              = data_settings.value.luns
          }
        }
        dynamic "log_settings" {
          for_each = storage_configuration.value.log_settings == [] ? [] : storage_configuration.value.log_settings
          content {
            default_file_path   = log_settings.value.default_file_path
            luns                = log_settings.value.luns
          }
        }

        system_db_on_data_disk_enabled = storage_configuration.value.system_db_on_data_disk_enabled

        dynamic "temp_db_settings" {
          for_each = storage_configuration.value.temp_db_settings == [] ? [] : storage_configuration.value.temp_db_settings
          content {
            default_file_path         = temp_db_settings.value.default_file_path
            luns                      = temp_db_settings.value.luns
            data_file_count           = temp_db_settings.value.data_file_count
            data_file_size_mb         = temp_db_settings.value.data_file_size_mb
            data_file_growth_in_mb    = temp_db_settings.value.data_file_growth_in_mb
            log_file_size_mb          = temp_db_settings.value.log_file_size_mb
            log_file_growth_mb        = temp_db_settings.value.log_file_growth_mb
          }
        }
      }
    }

  dynamic "assessment" {
    for_each = each.value.assessment == [] ? [] : each.value.assessment
    content {
      enabled          = assessment.value.enabled
      run_immediately   = assessment.value.run_immediately
      dynamic "schedule" {
        for_each = assessment.value.schedule
        content {
          weekly_interval       = schedule.value.monthly_occurrence != null && schedule.value.weekly_interval == null || schedule.value.weekly_interval == "0" ? null : schedule.value.weekly_interval 
          monthly_occurrence    = schedule.value.weekly_interval != null && schedule.value.monthly_occurrence == null || schedule.value.monthly_occurrence == "0"  ? null : schedule.value.monthly_occurrence
          day_of_week           = schedule.value.day_of_week
          start_time            = schedule.value.start_time
        }
      }
    }
  }
  
  dynamic "wsfc_domain_credential" {
   for_each = each.value.wsfc_domain_credential == [] ? [] : each.value.wsfc_domain_credential
   content {
   cluster_bootstrap_account_password   = wsfc_domain_credential.value.cluster_bootstrap_account_password
   cluster_operator_account_password    = wsfc_domain_credential.value.cluster_operator_account_password
   sql_service_account_password         = wsfc_domain_credential.value.sql_service_account_password 
   }
  
  }

  # dynamic "timeouts" {
  #   for_each = storage_configuration.value.timeouts
  #   content {
  #     create = timeouts.value.create
  #     update = timeouts.value.update
  #     read   = timeouts.value.read
  #     delete = timeouts.value.delete
  #   }
  # }

}