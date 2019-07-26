####################################################################################################
# Aurora MySQL                                                                                     #
####################################################################################################

module "aurora_mysql_master" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-aurora//?ref=tf_0.12-upgrade"

  ##################
  # Required Configuration
  ##################

  subnets           = module.vpc.private_subnets
  security_groups   = [module.vpc.default_sg]
  name              = "aurora-mysql-master"
  engine            = "aurora-mysql"
  instance_class    = "db.t2.medium"
  storage_encrypted = true
  kms_key_id        = "arn:aws:kms:us-west-2:12345678910:key/44ff8a34-f234-45a1-809f-ecba974a44ca"
  binlog_format     = "MIXED"
  password          = data.aws_kms_secrets.rds_credentials.plaintext["password"]

  ##################
  # VPC Configuration
  ##################

  # existing_subnet_group           = "some-subnet-group-name"
  # instance_availability_zone_list = ["us-west-2a", "us-west-2b", "us-west-2a"]

  ##################
  # Backups and Maintenance
  ##################

  maintenance_window      = "Sat:16:00-Sat:17:00"
  backup_retention_period = 30
  backup_window           = "15:00-16:00"

  ##################
  # Basic RDS
  ##################

  dbname                   = "mydb"
  engine_version           = "5.7.mysql_aurora.2.04.5"
  engine_mode              = "provisioned"
  family                   = "aurora-mysql5.7"
  port                     = "3306"
  replica_instances        = 1
  skip_final_snapshot      = true
  backtrack_window         = 0 #0 = disable
  enable_delete_protection = false


  ##################
  # Route53 Record
  ##################

  create_internal_records        = true
  internal_record_cluster        = "writer.development.local"
  internal_record_cluster_reader = "reader.development.local"
  internal_zone_id               = "Z5JSOCKL"

  ##################
  # RDS Advanced
  ##################

  publicly_accessible        = false
  auto_minor_version_upgrade = true
  parameters = [
    {
      name  = "innodb_large_prefix"
      value = "1"
    }
  ]
  cluster_parameters = [
    {
      name  = "time_zone"
      value = "US/Pacific"
    }
  ]

  ##################
  # RDS Monitoring
  ##################

  notification_topic          = [aws_sns_topic.my_test_sns.arn]
  alarm_write_io_limit        = 100000
  alarm_read_io_limit         = 100000
  alarm_cpu_limit             = 60
  rackspace_alarms_enabled    = false
  rackspace_managed           = false
  monitoring_interval         = 30
  cloudwatch_logs_exports     = ["audit", "error"]
  performance_insights_enable = false

  ##################
  # Authentication information
  ##################

  username = "dbadmin"

  ##################
  # Other parameters
  ##################

  environment = "Development"
  tags = {
    SomeTag = "SomeValue"
  }
}

module "aurora_mysql_replica" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-aurora//?ref=tf_0.12-upgrade"

  providers = {
    aws = "aws.sydney"
  }

  ##################
  # Required Configuration
  ##################

  subnets           = module.vpc_dr.private_subnets
  security_groups   = [module.vpc_dr.default_sg]
  name              = "aurora-mysql-replica"
  engine            = "aurora-mysql"
  instance_class    = "db.t2.medium"
  storage_encrypted = true
  kms_key_id        = data.aws_kms_alias.rds_crr.target_key_arn
  binlog_format     = "MIXED"
  password          = data.aws_kms_secrets.rds_credentials.plaintext["password"]
  source_cluster    = module.aurora_mysql_master.cluster_id
  source_region     = data.aws_region.current_region.name

  ##################
  # VPC Configuration
  ##################

  # existing_subnet_group           = "some-subnet-group-name"
  # instance_availability_zone_list = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]

  ##################
  # Backups and Maintenance
  ##################

  maintenance_window      = "Sat:16:00-Sat:17:00"
  backup_retention_period = 30
  backup_window           = "15:00-16:00"

  ##################
  # Basic RDS
  ##################

  dbname                   = "mydb"
  engine_version           = "5.7.mysql_aurora.2.04.5"
  engine_mode              = "provisioned"
  family                   = "aurora-mysql5.7"
  port                     = "3306"
  replica_instances        = 0
  skip_final_snapshot      = true
  backtrack_window         = 0 #0 = disable
  enable_delete_protection = false

  ##################
  # Route53 Record
  ##################

  create_internal_records        = true
  internal_record_cluster        = "writer-dr.development.local"
  internal_record_cluster_reader = "reader-dr.development.local"
  internal_zone_id               = "Z5JSOCKL"

  ##################
  # RDS Advanced
  ##################

  publicly_accessible        = false
  auto_minor_version_upgrade = true
  parameters = [
    {
      name  = "innodb_large_prefix"
      value = "1"
    }
  ]
  # existing_parameter_group_name         = "some-parameter-group-name"
  cluster_parameters = [
    {
      name  = "time_zone"
      value = "Australia/Sydney"
    }
  ]

  ##################
  # RDS Monitoring
  ##################

  notification_topic       = [aws_sns_topic.my_test_sns_replica.arn]
  alarm_write_io_limit     = 100000
  alarm_read_io_limit      = 100000
  alarm_cpu_limit          = 60
  rackspace_alarms_enabled = false
  rackspace_managed        = false
  monitoring_interval      = 30
  cloudwatch_logs_exports  = ["audit", "error"]

  ##################
  # Other parameters
  ##################

  environment = "Development"
  tags = {
    SomeTag = "SomeValue"
  }
}
