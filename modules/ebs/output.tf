output "volume_id" {
  description = "ID of the created EBS volume"
  value       = aws_ebs_volume.data.id
}

output "device_name" {
  description = "Device name used to attach the EBS volume to EC2"
  value       = aws_volume_attachment.data_attach.device_name
}
