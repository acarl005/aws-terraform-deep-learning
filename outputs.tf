output "instance_id" {
  value = aws_instance.ec2.id
}

output "instance_user_name" {
  value = "ubuntu"
}

output "instance_elastic_ip" {
  value = aws_eip.tf.public_ip
}

output "instance_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "instance_public_dns" {
  value = aws_instance.ec2.public_dns
}

output "instance_private_ip" {
  value = aws_instance.ec2.private_ip
}

output "efs_dns" {
  value = aws_efs_mount_target.alpha.dns_name
}
