output "all_users" {
    value = aws_iam_user.createuser
}

output "all_users_arn" {
    value = values(aws_iam_user.createuser)[*].arn
}