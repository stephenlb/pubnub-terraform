# PubNub Terraform Module with Illuminate Integration

This Terraform module provisions a new PubNub App, an associated API Key, and sets up an Illuminate Business Object and Dashboard in an idempotent way.

## Table of Contents

- [PubNub Terraform Module with Illuminate Integration](#pubnub-terraform-module-with-illuminate-integration)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Example Configuration](#example-configuration)
  - [Dependencies](#dependencies)
  - [Authors](#authors)
  - [License](#license)

## Usage

To use this module, include it in your Terraform configuration and provide the necessary input variables:

```hcl
module "pubnub" {
  source = "./pubnub"  # path to your module

  email                        = var.pubnub_email
  password                     = var.pubnub_password
  account_id                   = var.pubnub_account_id
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
```

## Inputs

| Name                        | Description                                | Type    | Default | Required |
| --------------------------- | ------------------------------------------ | ------- | ------- | -------- |
| `email`                     | Email for PubNub authentication            | `string`| n/a     | yes      |
| `password`                  | Password for PubNub authentication         | `string`| n/a     | yes      |
| `account_id`                | PubNub Account ID                          | `number`| n/a     | yes      |
| `app_name`                  | Name of the new PubNub App                 | `string`| n/a     | yes      |
| `app_type`                  | Type of the PubNub App. 1 for default, 2 for chat | `number` | `1`     | no       |
| `key_name`                  | Name of the new PubNub API Key             | `string`| n/a     | yes      |
| `key_type`                  | Type of the PubNub Key. 1 for production, 0 for testing | `number` | `1`     | no       |
| `history`                   | Enable/Disable History                     | `number`| `1`     | no       |
| `message_storage_ttl`       | TTL for message storage                    | `number`| `30`    | no       |
| `lms`                       | Enable/Disable Large Message Support       | `number`| `0`     | no       |
| `max_message_size`          | Max message size                           | `number`| `1800`  | no       |
| `multiplexing`              | Enable/Disable Multiplexing                | `number`| `1`     | no       |
| `apns`                      | Enable/Disable APNs                        | `number`| `0`     | no       |
| `uls`                       | Enable/Disable ULS                         | `number`| `0`     | no       |
| `objects`                   | Enable/Disable Objects                     | `number`| `0`     | no       |
| `illuminate_base_url`       | Base URL for Illuminate API                | `string`| n/a     | yes      |
| `business_object_name`      | Name of the Illuminate Business Object     | `string`| n/a     | yes      |
| `business_object_description`| Description of the Illuminate Business Object | `string`| n/a     | yes   |
| `business_object_fields`    | Fields for the Illuminate Business Object  | `list(object({ name = string, jsonFieldType = string, isKeyset = bool, source = string, jsonPath = string }))` | n/a | yes |
| `dashboard_name`            | Name of the Illuminate Dashboard           | `string`| n/a     | yes      |
| `dashboard_date_range`      | Date range for the Illuminate Dashboard    | `string`| `30 minutes` | no    |
| `dashboard_charts`          | Charts for the Illuminate Dashboard        | `list(object({ name = string, metricId = string, metric = object({ name = string, measureId = string, businessObjectId = string, function = string, dimensionIds = list(string), evaluationWindow = number }), viewType = string, size = string, dimensionIds = list(string) }))` | n/a | yes |

## Outputs

| Name                   | Description                                       |
| ---------------------- | ------------------------------------------------- |
| `app_id`               | The ID of the created PubNub App                  |
| `key_id`               | The ID of the created PubNub API Key              |
| `business_object_id`   | The ID of the created Illuminate Business Object  |
| `dashboard_id`         | The ID of the created Illuminate Dashboard        |

## Example Configuration

Below is an example of how to use this module:

```hcl
provider "http" {}

module "pubnub" {
  source = "./pubnub"

  email                        = "your-email@example.com"
  password                     = "your-password"
  account_id                   = 123456
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
```

## Dependencies

This module requires the following:

- `jq` - Command-line JSON processor
- `curl` - Command-line tool for transferring data with URLs

Make sure `jq` and `curl` are installed on your system.

## Authors

- [Stephen Blum](https://github.com/stephenlb)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
