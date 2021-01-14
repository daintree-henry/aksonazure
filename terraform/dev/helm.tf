resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "helm_release" "nginx_ingress" {
  depends_on = [kubernetes_namespace.ingress]
  name       = "nginx-ingress-controller"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace = "ingress"

  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  
  set {
    name  = "controller.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }
  
  set {
    name  = "defaultBackend.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = "100.64.2.4"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal-subnet"
    value = azurerm_subnet.svcsubnet.name
  }
}
