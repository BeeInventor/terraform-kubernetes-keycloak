resource "kubernetes_service" "headless" {
	metadata {
		name = "${var.name}-headless"
		namespace = var.namespace
		labels = {
			"app.kubernetes.io/component" = "headless"
		}
	}
	
	spec {
		type = "ClusterIP"
		cluster_ip = "None"
		port {
			name = "http"
			port = 80
			target_port = "http"
			protocol = "TCP"
		}
		selector = local.selector_labels
	}
}

resource "kubernetes_service" "http" {
	metadata {
		name = "${var.name}-http"
		namespace = var.namespace
		labels = {
			"app.kubernetes.io/component" = "http"
		}
	}
	
	spec {
		type = "ClusterIP"
		port {
			name = "http"
			port = 80
			target_port = "http"
			protocol = "TCP"
		}
		port {
			name = "https"
			port = 443
			target_port = "https"
			protocol = "TCP"
		}
		port {
			name = "http-management"
			port = 9990
			target_port = "http-management"
			protocol = "TCP"
		}
		selector = local.selector_labels
	}
}