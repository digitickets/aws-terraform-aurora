###############################################################################
# Outputs
# terraform output summary
###############################################################################

output "summary" {
  value = <<EOF
## Outputs
| cluster_endpoint_address    | ${module.aurora_mysql_master.cluster_endpoint_address} |
| cluster_endpoint_port       | ${module.aurora_mysql_master.cluster_endpoint_port} |
| cluster_endpoint_reader     | ${module.aurora_mysql_master.cluster_endpoint_reader} |
| cluster_id                  | ${module.aurora_mysql_master.cluster_id} |
| db_instance                 | ${join(",", module.aurora_mysql_master.db_instance)} |
| monitoring_role             | ${module.aurora_mysql_master.monitoring_role} |
| parameter_group             | ${module.aurora_mysql_master.parameter_group} |
| subnet_group                | ${module.aurora_mysql_master.subnet_group} |
EOF

  description = "aurora master output summary"
}
