locals {
	namespace = "default"
	db = {
		name = "keycloak"
		username = "keycloak"
		password = "keycloak"
	}
}

module "keycloak" {
	source = "../src"
	
	image = "mihaibob/keycloak:15.0.1"
	env = {
		DB_VENDOR = "postgres"
		DB_ADDR = module.postgresql.hostname
		DB_PORT = module.postgresql.port
		DB_DATABASE = local.db.name
		DB_USER = local.db.username
		DB_PASSWORD = local.db.password
		
  	KEYCLOAK_USER = "admin"
  	KEYCLOAK_PASSWORD = "admin"
	}
	
	startup_scripts = {
		"test.sh" = "#!/bin/sh\necho 'Hello from my custom startup script!'"
	}
}

module "postgresql" {
  source  = "ballj/postgresql/kubernetes"
  version = "1.1.0"
  # insert the 7 required variables here
	
	namespace = local.namespace
	object_prefix = "keycloak-postgresql"
	
	name = local.db.name # database name
	username = local.db.username
	password_secret = kubernetes_secret.postgresql_password.metadata[0].name
	password_key = "password"
}

resource "kubernetes_secret" "postgresql_password" {
	metadata {
    name      = "postgresql-password"
    namespace = local.namespace
  }

  data = {
    password = local.db.password
  }
}