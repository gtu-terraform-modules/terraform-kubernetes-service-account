variable "service_account_name" {
  description = "The name of the Service Account to create"
  type        = string
}

variable "service_account_namespace" {
  description = "The namespace in which to create the resources"
  type        = string
  default     = "default"
}

variable "create_role" {
  description = "Set to true to create a namespaced Role."
  type        = bool
  default     = false
}

variable "role_name" {
  description = "The name of the Role to create"
  type        = string
  default     = null
}

variable "role_binding_name" {
  description = "The name of the RoleBinding to create"
  type        = string
  default     = null
}

variable "role_permissions" {
  description = "Permissions for the role"
  type = list(object({
    api_groups        = list(string) # Example: ["apps"]
    resources         = list(string) # Example: ["pods"]
    verbs             = list(string) # Example: ["get", "list"]
  }))
  default = null
}

variable "create_cluster_role" {
  description = "Set to true to create a ClusterRole."
  type        = bool
  default     = false
}

variable "cluster_role_name" {
  description = "The name of the ClusterRole to create"
  type        = string
  default     = null
}

variable "cluster_role_binding_name" {
  description = "The name of the ClusterRoleBinding to create"
  type        = string
  default     = null
}

variable "cluster_role_permissions" {
  description = "Permissions for the cluster role"
  type = list(object({
    api_groups        = optional(list(string)) # Example: ["apps"]
    resources         = optional(list(string)) # Example: ["pods"]
    non_resource_urls = optional(list(string)) # Example: ["/healthz"]
    verbs             = list(string) # Example: ["get", "list"]
  }))
  default = null

  validation {
    condition     = alltrue([
      for r in var.cluster_role_permissions :
      !(r.resources != null && r.non_resource_urls != null)
    ])
    error_message = "Each rule in cluster_role_permissions must not have both resources and non_resource_urls defined at the same time."
  }

  validation {
    condition     = alltrue([for r in var.cluster_role_permissions : length(r.verbs) > 0])
    error_message = "Each rule in cluster_role_permissions must have at least one verb defined."
  }
}
