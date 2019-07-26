####################################################################################################
# Aurora Postgresql                                                                                     #
####################################################################################################

module "aurora_postgresql_master" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-aurora//?ref=tf_0.12-upgrade"

  ##################
  # Required Configuration
  ##################

  subnets           = module.vpc.private_subnets
  security_groups   = [module.vpc.default_sg]
  name              = "aurora-postgres-master"
  engine            = "aurora-postgresql"
  instance_class    = "db.t3.medium"
  storage_encrypted = true
  kms_key_id        = "arn:aws:kms:us-west-2:12345678910:key/44ff8a34-FFFF-FFFF-FFFF-ecba974a44ca"
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

  dbname                   = "postgres"
  engine_version           = "10.7"
  engine_mode              = "provisioned"
  family                   = "aurora-postgresql10"
  port                     = "5432"
  replica_instances        = 1
  skip_final_snapshot      = true
  backtrack_window         = 0 #0 = disable
  enable_delete_protection = false


  ##################
  # Route53 Record
  ##################

  create_internal_records        = true
  internal_record_cluster        = "pgwriter.development.local"
  internal_record_cluster_reader = "pgreader.development.local"
  internal_zone_id               = "Z5JSOCKL"

  ##################
  # RDS Advanced
  ##################

  publicly_accessible        = false
  auto_minor_version_upgrade = true
  parameters = [
    {
      name  = "auto_explain.log_buffers"
      value = "1"
    }
  ]
  cluster_parameters = [
    {
      name  = "timezone"
      value = "US/Pacific"
    }
  ]

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

