resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data_replace_on_change = true

user_data = <<-USERDATA
  #!/bin/bash
  set -e

  apt-get update -y
  apt-get install -y nginx

  # Find EBS device (Nitro safe)
  DEV_LINK=""
  while [ -z "$DEV_LINK" ]; do
    DEV_LINK=$(ls -1 /dev/disk/by-id/ 2>/dev/null | grep -i 'Amazon_Elastic_Block_Store' | head -n 1 || true)
    sleep 2
  done

  DEVICE="/dev/disk/by-id/$DEV_LINK"

  # Format if empty
  if ! blkid "$DEVICE" >/dev/null 2>&1; then
    mkfs.ext4 -F "$DEVICE"
  fi

  mkdir -p /data
  mount "$DEVICE" /data

  # Persist across reboot
  UUID=$(blkid -s UUID -o value "$DEVICE")
  echo "UUID=$UUID /data ext4 defaults,nofail 0 2" >> /etc/fstab

  systemctl enable nginx
  systemctl start nginx
  echo "<h1>EBS mounted on /data</h1>" > /var/www/html/index.html
USERDATA

  
  tags = {
    Name = "${var.name_prefix}-web"
  }
}