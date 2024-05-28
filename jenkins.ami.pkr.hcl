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

  provisioner "shell" {
    scripts = [
      "./scripts/jenkins-install.sh",
    ]
  }

  provisioner "shell" {
    scripts = [
      "./scripts/caddy-install.sh",
    ]
  }

  provisioner "shell" {
    scripts = [
      "./scripts/install-go.sh",
    ]
  }

  # Copy the Jcasc.yml file to a /home/ubuntu location
  provisioner "file" {
    source      = "jenkins/jcasc.yml"
    destination = "/home/ubuntu/jcasc.yml"
  }

  # Copy the plugins.txt file to a /home/ubuntu location
  provisioner "file" {
    source      = "jenkins/plugins.txt"
    destination = "/home/ubuntu/plugins.txt"
  }

  # Copy the Groovy script to the /home/ubuntu location
  provisioner "file" {
    source      = "jenkins/jenkins-UserSetUp.groovy"
    destination = "/home/ubuntu/jenkins-UserSetUp.groovy"
  }

  provisioner "shell" {
    scripts = [
      "./scripts/Jenkins-AutoPlugin-SetUp.sh",
    ]
  }

  provisioner "shell" {
    inline = [
      "java -jar /tmp/jenkins-cli.jar -auth admin:admin -s http://localhost:8080/ groovy = /home/ubuntu/jenkins-UserSetUp.groovy"
    ]
  }

  # Uncomment this section if you want to restrict AMI access to team members
  # post-processor "shell-local" {
  #   inline = [
  #     "aws ec2 modify-image-attribute --image-id {{ .BuildAmiID }} --launch-permission 'Add={AccountId=${join(\",\", var.team_account_ids)}}' --region ${var.aws_region}"
  #   ]
  # }
}
