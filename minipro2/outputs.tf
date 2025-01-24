output "web_url" {
  value = "http://${module.alb.alb_dns_name}"
}

output "db_address" {
  value = module.db.db_address
}