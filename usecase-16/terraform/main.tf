terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
}

resource "kubernetes_namespace_v1" "drift_lab" {
  metadata {
    name = "claims-drift-lab"

    labels = {
      managed-by = "terraform"
      use-case   = "16"
      purpose    = "configuration-drift-lab"
    }
  }
}

output "namespace_name" {
  value = kubernetes_namespace_v1.drift_lab.metadata[0].name
}
