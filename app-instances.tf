/* Setup our aws provider */
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

resource "aws_instance" "master" {
  ami           = "ami-26c43149"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.swarm.name}"]
  key_name = "${var.key_name}"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl apt-transport-https ca-certificates software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo sh -c 'echo \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list'",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce",
      "sudo groupadd docker",
      "sudo usermod -aG docker ubuntu"
    ]
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("${var.priv_key}")}"
    }
  }

  provisioner "file" {
    source = "proj"
    destination = "/home/ubuntu/"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("${var.priv_key}")}"
    }
  }

  tags = { 
    Name = "swarm-master"
  }
}

resource "aws_instance" "slave" {
  count         = 2
  ami           = "ami-26c43149"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.swarm.name}"]
  key_name = "${var.key_name}"


  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl apt-transport-https ca-certificates software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo sh -c 'echo \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list'",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce",
      "sudo groupadd docker",
      "sudo usermod -aG docker ubuntu"
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("/vagrant/ghe.megaleo/aws_keys/inf-net-stg-frank.pem")}"
    }
  }
  tags = { 
    Name = "swarm-${count.index}"
  }
}