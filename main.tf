   variable "pubnub_email" {
     description = "Email for PubNub authentication"
     type        = string
   }
   
   variable "pubnub_password" {
     description = "Password for PubNub authentication"
     type        = string
     sensitive   = true
   }
   
   variable "pubnub_account_id" {
     description = "PubNub Account ID"
     type        = number
   }

   variable "subscribe_key" {
     description = "PubNub Subscribe Key"
     type        = string
   }
   
   
   provider "http" {}
   
   module "pubnub" {
     source = "./pubnub"  # path to your module
   
     email                        = var.pubnub_email
     password                     = var.pubnub_password
     account_id                   = var.pubnub_account_id
     subscribe_key                = var.subscribe_key
     app_name                     = "My Awesome PubNub App"
     key_name                     = "Primary API Key"
     app_type                     = 1
     key_type                     = 1
     history                      = 1
     message_storage_ttl          = 30
     lms                          = 0
     max_message_size             = 1800
     multiplexing                 = 1
     apns                         = 0
     uls                          = 0
     objects                      = 0
     illuminate_base_url          = "admin.pubnub.com"
     business_object_name         = "My Business Object"
     business_object_description  = "Description of my business object"
     business_object_fields       = [
       {
         name           = "Field1"
         jsonFieldType  = "TEXT"
         isKeyset       = false
         source         = "JSONPATH"
         jsonPath       = "$.message.body.field1"
       }
     ]
     dashboard_name               = "My Dashboard"
     dashboard_date_range         = "30 minutes"
     dashboard_charts             = [
       {
         name           = "Chart1"
         metricId       = ""
         metric         = {
           name            = "Metric1"
           measureId       = "measureId1"
           businessObjectId = "businessObjectId1"
           function        = "AVG"
           dimensionIds    = ["dimensionId1"]
           evaluationWindow= 60
         }
         viewType       = "STACKED"
         size           = "HALF"
         dimensionIds   = ["dimensionId1"]
       }
     ]
   }
   
   output "app_id" {
     value = module.pubnub.app_id
   }
   
   output "key_id" {
     value = module.pubnub.key_id
   }
   
   output "business_object_id" {
     value = module.pubnub.business_object_id
   }
   
   output "dashboard_id" {
     value = module.pubnub.dashboard_id
   }
