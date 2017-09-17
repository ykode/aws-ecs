data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-xenial-*"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = "${data.aws_ami.bastion.image_id}"
  source_dest_check      = false
  instance_type          = "${var.bastion_instance_type}"
  subnet_id              = "${element(aws_subnet.external.*.id, 0)}"
  key_name               = "${aws_key_pair.main.key_name}"
  vpc_security_group_ids = ["${aws_security_group.external_ssh.id}"]
  monitoring             = true

  tags = {
    Name        = "bastion-${var.name}-${var.environment}"
    environment = "${var.environment}"
  }
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

output "bastion_external_ip" {
  value = "${aws_eip.bastion.public_ip}"
}
