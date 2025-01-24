output "myalb_dns_name" {
    value = aws_lb.mylb.dns_name
    description = "WEB DNS name"
}