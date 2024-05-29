packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name" {
  type    = string
  default = "jenkins-ami"
}

variable "team_account_ids" {
  type    = list(string)
  default = ["058264431172"] # Replace with your team's AWS account IDs
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name}-{{timestamp}}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami    = "ami-04b70fa74e45c3917"
  ssh_username  = "ubuntu"
  communicator  = "ssh"

  # Ensure EBS volume is deleted on termination
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  # Copy necessary files first
  provisioner "file" {
    source      = "./jenkins/jenkins.yaml"
    destination = "/home/ubuntu/jenkins.yaml"
  }

  provisioner "file" {
    source      = "./jenkins/plugins.txt"
    destination = "/home/ubuntu/plugins.txt"
  }

  provisioner "shell" {
    scripts = [
      "./scripts/install.sh",
    ]
  }
}
