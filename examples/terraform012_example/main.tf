###############################################################################
# Providers
###############################################################################
provider "aws" {
  version             = "~> 2.0"
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "sydney"
}


provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}

terraform {
  required_version = ">= 0.12"
}


###############################################################################
# Master Resources - Oregon Region
###############################################################################

data "aws_region" "current_region" {
}

module "vpc" {
  source   = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=tf_0.12-upgrade"
  vpc_name = "${var.environment}-${var.app_name}"
}

# # https://www.terraform.io/docs/providers/aws/d/kms_secrets.html
data "aws_kms_secrets" "rds_credentials" {
  secret {
    name    = "password"
    payload = "AQICAHiaAICcpwcfSogAA6yV3EvbeGOmvqExjQLrV8rTH03uCQFfxI020Ntog4iUDbFJl10OAAAAbTBrBgkqhkiG9w0BBwagXjBcAgEAMFcGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMJhoqUOc11I//mb5EAgEQgCp2Q/En7h7Ot0yt3zSH4T16N2X4lL4T6uWhjbmTzX+cswYf1Nld9sM76xE="
  }
}

resource "aws_sns_topic" "my_test_sns" {
  name = "user-notification-topic"
}

###############################################################################
# Replica Resources - Sydney Region
###############################################################################

module "vpc_dr" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=tf_0.12-upgrade"
  providers = {
    aws = "aws.sydney"
  }

  vpc_name = "${var.environment}-${var.app_name}-Replica"
}

resource "aws_sns_topic" "my_test_sns_replica" {
  provider = "aws.sydney"
  name     = "user-notification-topic"
}

data "aws_kms_alias" "rds_crr" {
  provider = "aws.sydney"
  name     = "alias/aws/rds"
}

