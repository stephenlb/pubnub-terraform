variable "email" {
  description = "Email for PubNub authentication"
  type = string
}

variable "password" {
  description = "Password for PubNub authentication"
  type = string
  sensitive = true
}

variable "account_id" {
  description = "PubNub Account ID"
  type = number
}

variable "app_name" {
  description = "Name of the new PubNub App"
  type = string
}

variable "app_type" {
  description = "Type of the PubNub App. 1 for default, 2 for chat"
  type = number
  default = 1
}

variable "key_type" {
  description = "Type of the PubNub Key. 1 for production, 0 for testing"
  type = number
  default = 1
}

variable "key_name" {
  description = "Name of the new PubNub API Key"
  type = string
}

variable "history" {
  description = "Enable/Disable History"
  type = number
  default = 1
}

variable "message_storage_ttl" {
  description = "TTL for message storage"
  type = number
  default = 30
}

variable "lms" {
  description = "Enable/Disable Large Message Support"
  type = number
  default = 0
}

variable "max_message_size" {
  description = "Max message size"
  type = number
  default = 1800
}

variable "multiplexing" {
  description = "Enable/Disable Multiplexing"
  type = number
  default = 1
}

variable "apns" {
  description = "Enable/Disable APNs"
  type = number
  default = 0
}

variable "uls" {
  description = "Enable/Disable ULS"
  type = number
  default = 0
}

variable "objects" {
  description = "Enable/Disable Objects"
  type = number
  default = 0
}
