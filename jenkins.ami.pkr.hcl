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
  default = ["058264431172"]  # Replace with your team's AWS account IDs
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_name}-{{timestamp}}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami    = "ami-04b70fa74e45c3917"
  ssh_username  = "ubuntu"
  ssh_interface        = "session_manager"
  communicator         = "ssh"

  # Ensure EBS volume is deleted on termination
     # Ensure EBS volume is deleted on termination
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }
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
#  # only the team members can access the ami
#   post-processor "shell-local" {
#     inline = [
#       "aws ec2 modify-image-attribute --image-id {{ .BuildAmiID }} --launch-permission 'Add={AccountId=${join(\",\", var.team_account_ids)}}' --region ${var.aws_region}"
#     ]
#   }
}
