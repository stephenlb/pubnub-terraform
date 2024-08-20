```hcl
provider "http" {}

resource "random_password" "session_token_password" {
  length = 20
  special = true
}

resource "null_resource" "pubnub_app_setup" {
  provisioner "local-exec" {
    command = <<EOT
      curl --request POST "https://admin.pubnub.com/api/me" \
      --header "Content-Type: application/json" \
      --data-raw '{
          "email": "${var.email}",
          "password": "${var.password}"
      }' | jq -r '.result.token' > session_token.txt
    EOT
  }
}

resource "null_resource" "create_pubnub_app" {
  provisioner "local-exec" {
    command = <<EOT
      export SESSION_TOKEN=$(cat session_token.txt)
      curl --request POST "https://admin.pubnub.com/api/apps" \
      --header "X-Session-Token: $${SESSION_TOKEN}" \
      --header "Content-Type: application/json" \
      --data-raw '{
          "owner_id": ${var.account_id},
          "name": "${var.app_name}",
          "properties": {
              "app_type": ${var.app_type}
          }
      }' | jq -r '.result.id' > app_id.txt
    EOT
    depends_on = [null_resource.pubnub_app_setup]
  }
}

resource "null_resource" "create_pubnub_api_key" {
  provisioner "local-exec" {
    command = <<EOT
      export SESSION_TOKEN=$(cat session_token.txt)
      export APP_ID=$(cat app_id.txt)
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
      }' | jq -r '.result.id' > key_id.txt
    EOT
    depends_on = [null_resource.create_pubnub_app]
  }
}

output "app_id" {
  value = file("app_id.txt")
}

output "key_id" {
  value = file("key_id.txt")
}
