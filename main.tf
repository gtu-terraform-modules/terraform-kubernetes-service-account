resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = var.service_account_name
    namespace = var.service_account_namespace
  }

  automount_service_account_token = var.automount_service_account_token
}

resource "kubernetes_role" "this" {
  count = var.create_role ? 1 : 0

  metadata {
    name      = var.role_name
    namespace = var.service_account_namespace
  }

  dynamic "rule" {
    for_each = var.role_permissions
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role" "this" {
  count = var.create_cluster_role ? 1 : 0

  metadata {
    name = var.cluster_role_name
  }

  dynamic "rule" {
    for_each = var.cluster_role_permissions
    content {
      api_groups        = rule.value.api_groups
      resources         = rule.value.resources
      non_resource_urls = rule.value.non_resource_urls
      verbs             = rule.value.verbs
    }
  }
}

resource "kubernetes_role_binding" "this" {
  count = var.create_role ? 1 : 0

  metadata {
    name      = var.role_binding_name
    namespace = var.service_account_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.this[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this.metadata[0].name
    namespace = var.service_account_namespace
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  count = var.create_cluster_role ? 1 : 0

  metadata {
    name = var.cluster_role_binding_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this.metadata[0].name
    namespace = var.service_account_namespace
  }
}

resource "kubernetes_secret_v1" "this" {
  metadata {
    namespace = var.service_account_namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.this.metadata[0].name
    }

    generate_name = "${kubernetes_service_account_v1.this.metadata[0].name}-token-"
  }

  type = "kubernetes.io/service-account-token"
}
