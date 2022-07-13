locals {
  creation_date = formatdate("YYYY-MM-DD", timestamp())
}

source "amazon-ebs" "centos" {
  ami_name      = "centos-9-arm64-${local.creation_date}"
  instance_type = "t4g.micro"
  region        = "us-east-1"
  ssh_username = "centos"

  source_ami_filter {
    filters = {
      name                = "CentOS Stream 9*"
      architecture        = "arm64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["125523088429"]
  }

}

build {
  name = "build"
  sources = [
    "source.amazon-ebs.centos"
  ]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo sed -i 's/cloud_config_modules:/&\\n - yum_add_repo/' /etc/cloud/cloud.cfg",
    ]
  }
}
