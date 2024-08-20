## Fast Setup

### Step 1: Clone Repository

Clone repository and navigate to the directory.

```shell
git clone https://github.com/stephenlb/pubnub-terraform-module.git
cd pubnub-terraform-module
```

### Step 2: Edit `terraform.tfvars`

Edit the `terraform.tfvars` file and add your account access details.
Your account ID can be found in the URL of your account page.


### Step 3: Edit `main.tf`

Modify the `main.tf` file to perform the actions you need.


### Step 4: Run

> OPTIONAL: When you are using `tfenv` then install the version compatible with this module.

```shell
tfenv install 1.9.5
tfenv use 1.9.5
```

Ready to go!

```shell
terraform init
terraform apply
```

That's it! There's more details on the instructions below. However, you can stop here if everything worked.

Here's a step-by-step guide on how to the PubNub Terrafor Module. Save the files, and run `terraform apply` commands to provision your PubNub App, API Key, and Illuminate setup.

### Advanced Step-by-Step Instructions

#### Step 1: Prepare the Directory Structure

Create a directory for your Terraform configuration and module files.

```sh
mkdir -p terraform/pubnub_module_example/pubnub
cd terraform/pubnub_module_example
```

#### Step 2: Create the Module Files

Copy the necessary files for the Terraform module files in `./pubnub` directory which are: `main.tf`, `variables.tf`, and `outputs.tf`.

#### Step 3: Create the Main Configuration File

Create a new file `main.tf` in your working directory (outside the module directory) to call the module:

```sh
touch main.tf
```

Edit `main.tf` with the following content:

```hcl
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

provider "http" {}

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

#### Step 4: Provide Variables

Create a `terraform.tfvars` file to store your variable values:

```sh
touch terraform.tfvars
```

Edit `terraform.tfvars` with your actual variable values:

```hcl
pubnub_email              = "your-email@example.com"
pubnub_password           = "your-password"
pubnub_account_id         = 123456
```

#### Step 5: Initialize and Apply Terraform Configuration

Run the following commands to initialize and apply your configuration:

```sh
terraform init
terraform apply
```

These commands will initialize your Terraform environment, download the required providers and modules, and apply the configuration to provision the PubNub resources and Illuminate setup.

#### Step 6: Verify Outputs

After running `terraform apply`, Terraform will display the outputs defined in the module:

```sh
Outputs:

app_id = <PubNub App ID>
key_id = <PubNub API Key ID>
business_object_id = <Illuminate Business Object ID>
dashboard_id = <Illuminate Dashboard ID>
```

These values can be used for further integration or validation.
