variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name" {
  type    = string
  default = "jenkins-ami"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name}-{{timestamp}}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username                = "ubuntu"
  associate_public_ip_address = false
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "scripts/install-jenkins.sh"
    destination = "/tmp/install-jenkins.sh"
  }

  provisioner "file" {
    source      = "scripts/install-caddy.sh"
    destination = "/tmp/install-caddy.sh"
  }

  provisioner "file" {
    source      = "scripts/configure-caddy.sh"
    destination = "/tmp/configure-caddy.sh"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install-jenkins.sh",
      "chmod +x /tmp/install-caddy.sh",
      "chmod +x /tmp/configure-caddy.sh",
      "/tmp/install-jenkins.sh",
      "/tmp/install-caddy.sh",
      "/tmp/configure-caddy.sh"
    ]
  }
}
