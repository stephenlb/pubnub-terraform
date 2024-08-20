# PubNub Terraform Module

This Terraform module provisions a new PubNub App and associated API Key.

## Table of Contents

- [PubNub Terraform Module](#pubnub-terraform-module)
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

  email               = var.pubnub_email
  password            = var.pubnub_password
  account_id          = var.pubnub_account_id
  app_name            = "My Awesome PubNub App"
  key_name            = "Primary API Key"
  app_type            = 1
  key_type            = 1
  history             = 1
  message_storage_ttl = 30
  lms                 = 0
  max_message_size    = 1800
  multiplexing        = 1
  apns                = 0
  uls                 = 0
  objects             = 0
}

output "app_id" {
  value = module.pubnub.app_id
}

output "key_id" {
  value = module.pubnub.key_id
}
```

## Inputs

| Name                   | Description                                | Type    | Default | Required |
| ---------------------- | ------------------------------------------ | ------- | ------- | -------- |
| `email`                | Email for PubNub authentication            | `string`| n/a     | yes      |
| `password`             | Password for PubNub authentication         | `string`| n/a     | yes      |
| `account_id`           | PubNub Account ID                          | `number`| n/a     | yes      |
| `app_name`             | Name of the new PubNub App                 | `string`| n/a     | yes      |
| `app_type`             | Type of the PubNub App. 1 for default, 2 for chat | `number` | `1`     | no       |
| `key_name`             | Name of the new PubNub API Key             | `string`| n/a     | yes      |
| `key_type`             | Type of the PubNub Key. 1 for production, 0 for testing | `number` | `1`     | no       |
| `history`              | Enable/Disable History                     | `number`| `1`     | no       |
| `message_storage_ttl`  | TTL for message storage                    | `number`| `30`    | no       |
| `lms`                  | Enable/Disable Large Message Support       | `number`| `0`     | no       |
| `max_message_size`     | Max message size                           | `number`| `1800`  | no       |
| `multiplexing`         | Enable/Disable Multiplexing                | `number`| `1`     | no       |
| `apns`                 | Enable/Disable APNs                        | `number`| `0`     | no       |
| `uls`                  | Enable/Disable ULS                         | `number`| `0`     | no       |
| `objects`              | Enable/Disable Objects                     | `number`| `0`     | no       |

## Outputs

| Name     | Description                                   |
| -------- | --------------------------------------------- |
| `app_id` | The ID of the created PubNub App              |
| `key_id` | The ID of the created PubNub API Key          |

## Example Configuration

Below is an example of how to use this module:

```hcl
provider "http" {}

module "pubnub" {
  source = "github.com/your-org/pubnub-terraform-module"

  email               = "your-email@example.com"
  password            = "your-password"
  account_id          = 123456
  app_name            = "My Awesome PubNub App"
  key_name            = "Primary API Key"
  app_type            = 1
  key_type            = 1
  history             = 1
  message_storage_ttl = 30
  lms                 = 0
  max_message_size    = 1800
  multiplexing        = 1
  apns                = 0
  uls                 = 0
  objects             = 0
}

output "app_id" {
  value = module.pubnub.app_id
}

output "key_id" {
  value = module.pubnub.key_id
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

### Explanation

- The `Usage` section contains a basic example of how to use the module in a Terraform configuration.
- The `Inputs` section lists all the variables with descriptions, types, and defaults.
- The `Outputs` section lists all the outputs provided by the module.
- The `Example Configuration` section shows a complete configuration example.
- The `Dependencies` section lists external tools that should be installed (`jq` and `curl`).
- The `Authors` and `License` sections provide information about the module author and licensing.
