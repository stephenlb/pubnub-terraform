output "app_id" {
  description = "The ID of the created PubNub App"
  value = file("app_id.txt")
}

output "key_id" {
  description = "The ID of the created PubNub API Key"
  value = file("key_id.txt")
}

output "business_object_id" {
  description = "The ID of the created Illuminate Business Object"
  value = file("business_object_id.txt")
}

output "dashboard_id" {
  description = "The ID of the created Illuminate Dashboard"
  value = file("dashboard_id.txt")
}
