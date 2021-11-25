locals {
  selector_labels = {
    "app.kubernetes.io/name": var.name
    # "app.kubernetes.io/instance": {{ .Release.Name }}
  }
  
  startup_scripts = {
		volume_name = "startup"
    entries = merge({
      "default.cli" = data.local_file.default_cli.content
    }, var.startup_scripts)
  }
}


data "local_file" "default_cli" {
    filename = "${path.module}/scripts/default.cli"
}