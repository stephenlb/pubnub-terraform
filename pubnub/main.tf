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

resource "null_resource" "pubnub_app_setup" {
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

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "create_pubnub_app" {
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
  }

  triggers = {
    session_token = "${null_resource.pubnub_app_setup.triggers.always_run}"
  }
}

resource "null_resource" "create_pubnub_api_key" {
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
  }

  triggers = {
    app_id = "${null_resource.create_pubnub_app.triggers.session_token}"
  }
}

resource "null_resource" "setup_illuminate_business_object" {
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
  }

  triggers = {
    key_id = "${null_resource.create_pubnub_api_key.triggers.app_id}"
  }
}

resource "null_resource" "activate_illuminate_business_object" {
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
  }

  triggers = {
    business_object_id = "${null_resource.setup_illuminate_business_object.triggers.key_id}"
  }
}

resource "null_resource" "create_illuminate_dashboard" {
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
    environment = {
      "BUSINESS_OBJECT_ID" = "$(cat ${local.business_object_id_file})"
    }
  }

  triggers = {
    activate_business_object = "${null_resource.activate_illuminate_business_object.triggers.business_object_id}"
  }
}

#output "app_id" {
#  description = "The ID of the created PubNub App"
#  value       = null_resource.create_pubnub_app.triggers.session_token
#}

#output "key_id" {
#  description = "The ID of the created PubNub API Key"
#  value       = null_resource.create_pubnub_api_key.triggers.app_id
#}

#output "business_object_id" {
#  description = "The ID of the created Illuminate Business Object"
#  value       = null_resource.setup_illuminate_business_object.triggers.key_id
#}

#output "dashboard_id" {
#  description = "The ID of the created Illuminate Dashboard"
#  value       = null_resource.create_illuminate_dashboard.triggers.activate_business_object
#}
