output "EC2_public_ip" {
    value = aws_instance.myDevServer.public_ip
    description = "EC2 public IP address"

}