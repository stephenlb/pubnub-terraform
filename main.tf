provider "http" {}

locals {
  session_token_file = "session_token.txt"
  app_id_file        = "app_id.txt"
  key_id_file        = "key_id.txt"
  business_object_id_file = "business_object_id.txt"
  dashboard_id_file  = "dashboard_id.txt"
}

resource "random_password" "session_token_password" {
  length  = 20
  special = true
}

# Authenticate and obtain session token, only if the file doesn't exist
resource "null_resource" "pubnub_app_setup" {
  # Skip the creation if the token file already exists
  triggers = {
    always_run = "${timestamp()}"
  }
  
  provisioner "local-exec" {
    command = <<EOT
      if [ ! -f "${local.session_token_file}" ]; then
        curl --request POST "https://admin.pubnub.com/api/me" \
        --header "Content-Type: application/json" \
        --data-raw '{
            "email": "${var.email}",
            "password": "${var.password}"
        }' | jq -r '.result.token' > "${local.session_token_file}";
      fi
    EOT
  }
}

# Create an App, only if the file doesn't exist
resource "null_resource" "create_pubnub_app" {
  # Skip the creation if the app_id file already exists
  triggers = {
    always_run = "${timestamp()}"
  }
  
  provisioner "local-exec" {
    command = <<EOT
      export SESSION_TOKEN=$(cat "${local.session_token_file}")
      if [ ! -f "${local.app_id_file}" ]; then
        curl --request POST "https://admin.pubnub.com/api/apps" \
        --header "X-Session-Token: $${SESSION_TOKEN}" \
        --header "Content-Type: application/json" \
        --data-raw '{
            "owner_id": ${var.account_id},
            "name": "${var.app_name}",
            "properties": {
                "app_type": ${var.app_type}
            }
        }' | jq -r '.result.id' > "${local.app_id_file}";
      fi
    EOT
    depends_on = [null_resource.pubnub_app_setup]
  }
}

# Create API key, only if the file doesn't exist
resource "null_resource" "create_pubnub_api_key" {
  triggers = {
    always_run = "${timestamp()}"
  }
  
  provisioner "local-exec" {
    command = <<EOT
      export SESSION_TOKEN=$(cat "${local.session_token_file}")
      export APP_ID=$(cat "${local.app_id_file}")
      if [ ! -f "${local.key_id_file}" ]; then
        curl --request POST "https://admin.pubnub.com/api/keys" \
        --header "X-Session-Token: $${SESSION_TOKEN}" \
        --header "Content-Type: application/json" \
        --data-raw '{
            "app_id" : $${APP_ID},
            "type": ${var.key_type},
            "properties": {
                "name" : "${var.key_name}",
                "history" : ${var.history},
                "message_storage_ttl" : ${var.message_storage_ttl},
                "lms" : ${var.lms},
                "max_message_size" : ${var.max_message_size},
                "multiplexing" : ${var.multiplexing},
                "apns" : ${var.apns},
                "uls" : ${var.uls},
                "objects" : ${var.objects}
            }
        }' | jq -r '.result.id' > "${local.key_id_file}";
      fi
    EOT
    depends_on = [null_resource.create_pubnub_app]
  }
}

# Setup Illuminate Business Object, if not already setup
resource "null_resource" "setup_illuminate_business_object" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      export SESSION_TOKEN=$(cat "${local.session_token_file}")
      export SUBSCRIBE_KEY=$(cat "${local.key_id_file}")
      if [ ! -f "${local.business_object_id_file}" ]; then
        curl --request POST "https://${var.illuminate_base_url}/api/illuminate/v1/accounts/${var.account_id}/business-objects" \
        --header "X-Session-Token: $${SESSION_TOKEN}" \
        --header "Content-Type: application/json" \
        --data-raw '{
            "name": "${var.business_object_name}",
            "description": "${var.business_object_description}",
            "isActive": false,
            "subkeys": ["${var.subscribe_key}"],
            "fields": ${jsonencode(var.business_object_fields)}
        }' | jq -r '.id' > "${local.business_object_id_file}";
      fi
    EOT
    depends_on = [null_resource.create_pubnub_api_key]
  }
}

resource "null_resource" "activate_illuminate_business_object" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      export SESSION_TOKEN=$(cat "${local.session_token_file}")
      export BUSINESS_OBJECT_ID=$(cat "${local.business_object_id_file}")
      curl --request PUT "https://${var.illuminate_base_url}/api/illuminate/v1/accounts/${var.account_id}/business-objects/$${BUSINESS_OBJECT_ID}" \
      --header "X-Session-Token: $${SESSION_TOKEN}" \
      --header "Content-Type: application/json" \
      --data-raw '{
          "isActive": true
      }'
    EOT
    depends_on = [null_resource.setup_illuminate_business_object]
  }
}

resource "null_resource" "create_illuminate_dashboard" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      export SESSION_TOKEN=$(cat "${local.session_token_file}")
      export BUSINESS_OBJECT_ID=$(cat "${local.business_object_id_file}")
      if [ ! -f "${local.dashboard_id_file}" ]; then
        curl --request POST "https://${var.illuminate_base_url}/api/illuminate/v1/accounts/${var.account_id}/dashboards" \
        --header "X-Session-Token: $${SESSION_TOKEN}" \
        --header "Content-Type: application/json" \
        --data-raw '{
            "name": "${var.dashboard_name}",
            "accountId": ${var.account_id},
            "dateRange": "${var.dashboard_date_range}",
            "charts": ${jsonencode(var.dashboard_charts)}
        }' | jq -r '.id' > "${local.dashboard_id_file}";
      fi
    EOT
    depends_on = [null_resource.activate_illuminate_business_object]
  }
}

output "app_id" {
  value = file(local.app_id_file)
}

output "key_id" {
  value = file(local.key_id_file)
}

output "business_object_id" {
  value = file(local.business_object_id_file)
}

output "dashboard_id" {
  value = file(local.dashboard_id_file)
}

## Authentication and Session Token Retrieval:
# A `null_resource` is used to retrieve a session token only if a file containing the session token does not already exist. 
# This ensures that the session token is fetched once and reused in subsequent runs.

## App Creation:
# A `null_resource` is used to create a new PubNub app only if an app ID file does not already exist. This ensures that the app creation process is idempotent.

## API Key Creation:
# A `null_resource` is used to create a new API key only if a key ID file does not already exist. This ensures that the API key creation process is idempotent.

## Illuminate Business Object Setup:
# A `null_resource` is used to set up the Illuminate business object only if it's not already set up, indicated by the presence of the business object ID file.

## Activate Illuminate Business Object:
# A `null_resource` is used to activate the Illuminate business object after it has been set up.

## Creating Illuminate Dashboard:
# A `null_resource` is used to create an Illuminate dashboard only if it is not already created, indicated by the presence of the dashboard ID file.

## Note:
# The `triggers` block with a dynamic trigger such as `always_run` ensures that the resource is evaluated during every Terraform apply. By combining this with file existence checks in the `local-exec` commands, we achieve idempotency. 

## Dependencies:
# Make sure you have `jq` and `curl` installed, as they are necessary for processing API responses and making HTTP requests:
# 
# - `jq`: Command-line JSON processor
# - `curl`: Command-line tool for transferring data with URLs

