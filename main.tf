# you'll need to provide credentials in ~/.aws/credentials
# make sure you add the key and secret under the [terraform] profile
provider aws {
  region  = "us-east-1"
  profile = "terraform"
}

# first do something like `ssh-keygen -t rsa -C youremail@example.org`
# after picking a file path, call ssh-add on the generated private key
# then you'll provide the public key to terraform
variable "public_key_file" {
  description = "file path to RSA public key file, e.g. ~/.ssh/rsa-key.pub (you'll need the associated private key to authenticate via SSH)"
}

variable "volume_size_gb" {
  description = "number of GB of storage for your volume"
  default     = 5
}

resource "aws_vpc" "tf" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "dedicated"
  enable_dns_hostnames = true

  tags {
    Name = "tf"
  }
}

# allow our VPC to talk to the public internet
resource "aws_internet_gateway" "tf" {
  vpc_id = "${aws_vpc.tf.id}"

  tags {
    Name = "tf"
  }
}

locals {
  # the deep learning AMI we want is only available in specific AZ's
  avail_zone = "us-east-1c"
}

# define the subnet to put our instance in
resource "aws_subnet" "tf" {
  vpc_id                  = "${aws_vpc.tf.id}"
  cidr_block              = "${aws_vpc.tf.cidr_block}"
  map_public_ip_on_launch = true
  availability_zone       = "${local.avail_zone}"

  tags {
    Name = "tf"
  }
}

# this is for the default route table that was created with our VPC
resource "aws_default_route_table" "rt" {
  default_route_table_id = "${aws_vpc.tf.default_route_table_id}"

  # make sure all outbound traffic goes through the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tf.id}"
  }

  tags {
    Name = "default table"
  }
}

# attach route table to the sbnet
resource "aws_route_table_association" "rt_assoc" {
  subnet_id      = "${aws_subnet.tf.id}"
  route_table_id = "${aws_vpc.tf.default_route_table_id}"
}

# permit inbound access to all the ports we need
resource "aws_security_group" "tf" {
  name   = "allow_8888"
  vpc_id = "${aws_vpc.tf.id}"

  # jupyter uses 8888 by default
  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # tensorboard uses 6006
  ingress {
    from_port   = 6006
    to_port     = 6006
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH uses 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # just allow everything outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "tf"
  }
}

# a volume to persist our model after training
resource "aws_ebs_volume" "tf" {
  availability_zone = "${local.avail_zone}"
  size              = "${var.volume_size_gb}"

  tags {
    Name = "tf"
  }
}

# to permit SSH access
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = "${file("${var.public_key_file}")}"
}

# the actual compute instance
resource "aws_instance" "ec2" {
  # this AMI has python, jupyter, tensorflow, etc preinstalled on Ubuntu!
  ami = "ami-7336d50e"

  # a type with a beefy GPU is required
  instance_type          = "p3.2xlarge"
  availability_zone      = "${local.avail_zone}"
  subnet_id              = "${aws_subnet.tf.id}"
  vpc_security_group_ids = ["${aws_security_group.tf.id}"]
  key_name               = "ssh_key"

  tags {
    Name = "tf"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.tf.id}"
  instance_id = "${aws_instance.ec2.id}"
}

output "instance_id" {
  value = "${aws_instance.ec2.id}"
}

output "instance_user_name" {
  value = "ubuntu"
}

output "instance_public_ip" {
  value = "${aws_instance.ec2.public_ip}"
}

output "instance_public_dns" {
  value = "${aws_instance.ec2.public_dns}"
}

output "instance_private_ip" {
  value = "${aws_instance.ec2.private_ip}"
}
