output "app_id" {
  description = "The ID of the created PubNub App"
  value = file("app_id.txt")
}

output "key_id" {
  description = "The ID of the created PubNub API Key"
  value = file("key_id.txt")
}
