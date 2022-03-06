resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.ec2_key_pair_name
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_instance" "this" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.az1a.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.key_name
  # iam_instance_profile        = aws_iam_instance_profile.instance.name
  user_data                   = file("userdata.ps1")

  root_block_device {
    volume_size = 100
  }

  tags = {
    Name = "${var.name}-${count.index}"
  }
}

resource "aws_ebs_volume" "f_volume" {
  count             = 2
  availability_zone = aws_instance.this[count.index].availability_zone
  size              = 20
  encrypted         = true

  tags = {
    Name = "nl-f-volume-${count.index}"
  }
}

resource "aws_ebs_volume" "g_volume" {
  count             = 2
  availability_zone = aws_instance.this[count.index].availability_zone
  size              = 10
  encrypted         = true

  tags = {
    Name = "nl-g-volume-${count.index}"
  }
}

resource "aws_volume_attachment" "f" {
  count       = 2
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.f_volume[count.index].id
  instance_id = aws_instance.this[count.index].id
}

resource "aws_volume_attachment" "g" {
  count       = 2
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.g_volume[count.index].id
  instance_id = aws_instance.this[count.index].id
}

