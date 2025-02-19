provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

provider "aws" {
  alias   = "secondary"
  version = "~> 2.0"
  region  = "us-west-2"
}

data "aws_kms_secrets" "rds_credentials" {
  secret {
    name    = "password"
    payload = "AQICAHj9P8B8y7UnmuH+/93CxzvYyt+la85NUwzunlBhHYQwSAG+eG8tr978ncilIYv5lj1OAAAAaDBmBgkqhkiG9w0BBwagWTBXAgEAMFIGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMoasNhkaRwpAX9sglAgEQgCVOmIaSSj/tJgEE5BLBBkq6FYjYcUm6Dd09rGPFdLBihGLCrx5H"
  }
}

resource "aws_rds_global_cluster" "example" {
  global_cluster_identifier = "global-aurora-example"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.1"

  vpc_name = "Test1VPC"
}

module "vpc_dr" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.1"

  providers = {
    aws = "aws.secondary"
  }

  vpc_name = "Test2VPC"
}

module "aurora_primary" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-aurora//?ref=v0.0.7"

  ##################
  # Required Configuration
  ##################

  subnets                   = "${module.vpc.private_subnets}"
  security_groups           = ["${module.vpc.default_sg}"]
  name                      = "aurora-primary"
  engine                    = "aurora"
  instance_class            = "db.r3.large"
  storage_encrypted         = false
  binlog_format             = "MIXED"
  password                  = "${data.aws_kms_secrets.rds_credentials.plaintext["password"]}"
  global_cluster_identifier = "${aws_rds_global_cluster.example.id}"
  engine_mode               = "global"

  ##################
  # VPC Configuration
  ##################

  # existing_subnet_group = "some-subnet-group-name"

  ##################
  # Backups and Maintenance
  ##################

  # maintenance_window      = "Sun:07:00-Sun:08:00"
  # backup_retention_period = 35
  # backup_window           = "05:00-06:00"
  # db_snapshot_arn          = "some-cluster-snapshot-arn"

  ##################
  # Basic RDS
  ##################

  # dbname         = "mydb"
  # engine_version = "5.6.10a"
  # port           = "3306"

  ##################
  # RDS Advanced
  ##################

  # publicly_accessible                   = false
  # binlog_format                         = "OFF"
  # auto_minor_version_upgrade            = true
  # family                                = "aurora5.6"
  # replica_instances                     = 1
  # storage_encrypted                     = false
  # kms_key_id                            = "some-kms-key-id"
  # parameters                            = []
  # existing_parameter_group_name         = "some-parameter-group-name"
  # cluster_parameters                    = []
  # existing_cluster_parameter_group_name = "some-parameter-group-name"
  # options                               = []
  # existing_option_group_name            = "some-option-group-name"

  ##################
  # RDS Monitoring
  ##################

  # notification_topic              = "arn:aws:sns:<region>:<account>:some-topic"
  # alarm_write_iops_limit          = 100000
  # alarm_read_iops_limit           = 100000
  # alarm_cpu_limit                 = 60
  # rackspace_alarms_enabled        = false
  # monitoring_interval             = 0
  # existing_monitoring_role_arn    = ""
  # cloudwatch_logs_exports         = []
  # performance_insights_enable     = false
  # performance_insights_kms_key_id = ""

  ##################
  # Authentication information
  ##################

  # username = "dbadmin"

  ##################
  # Other parameters
  ##################

  # environment = "Production"

  # tags = {
  #   SomeTag = "SomeValue"
  # }
}

#undo
#data "aws_kms_alias" "rds_crr" {
#  provider = "aws.oregon"
#  name     = "alias/aws/rds"
#}

module "aurora_secondary" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-aurora//?ref=v0.0.7"

  providers = {
    aws = "aws.secondary"
  }

  ##################
  # Required Configuration
  ##################

  subnets                   = "${module.vpc_dr.private_subnets}"
  security_groups           = ["${module.vpc_dr.default_sg}"]
  name                      = "aurora-secondary"
  engine                    = "aurora"
  instance_class            = "db.r3.large"
  storage_encrypted         = false
  binlog_format             = "MIXED"
  password                  = ""
  username                  = ""
  global_cluster_identifier = "${aws_rds_global_cluster.example.id}"
  engine_mode               = "global"

  ##################
  # VPC Configuration
  ##################


  # existing_subnet_group = "some-subnet-group-name"


  ##################
  # Backups and Maintenance
  ##################


  # maintenance_window      = "Sun:07:00-Sun:08:00"
  # backup_retention_period = 35
  # backup_window           = "05:00-06:00"
  # db_snapshot_arn          = "some-cluster-snapshot-arn"


  ##################
  # Basic RDS
  ##################


  # dbname         = "mydb"
  # engine_version = "5.6.10a"
  # port           = "3306"


  ##################
  # RDS Advanced
  ##################


  # publicly_accessible                   = false
  # binlog_format                         = "OFF"
  # auto_minor_version_upgrade            = true
  # family                                = "aurora5.6"
  # replica_instances                     = 1
  # storage_encrypted                     = false
  # kms_key_id                            = "some-kms-key-id"
  # parameters                            = []
  # existing_parameter_group_name         = "some-parameter-group-name"
  # cluster_parameters                    = []
  # existing_cluster_parameter_group_name = "some-parameter-group-name"
  # options                               = []
  # existing_option_group_name            = "some-option-group-name"


  ##################
  # RDS Monitoring
  ##################


  # notification_topic           = "arn:aws:sns:<region>:<account>:some-topic"
  # alarm_write_iops_limit       = 100000
  # alarm_read_iops_limit        = 100000
  # alarm_cpu_limit              = 60
  # rackspace_alarms_enabled     = false
  # monitoring_interval          = 0
  # existing_monitoring_role_arn = ""


  ##################
  # Authentication information
  ##################


  # username = "dbadmin"


  ##################
  # Other parameters
  ##################


  # environment = "Production"

  # HACK to give me a dependency between modules
  tags = {
    FakeDependency = "${module.aurora_primary.cluster_id}"
  }
}
