resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-web-sg"
  description = "SSH restricted + HTTP open"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-web-sg" })
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
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

  tags = merge(var.tags, { Name = "${var.name_prefix}-web" })
}
