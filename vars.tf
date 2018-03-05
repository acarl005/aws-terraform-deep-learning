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

variable "instance_type" {
  description = "the type of EC2 instance to run. should be one of the 'Accelerated Computing' types in the docs (https://aws.amazon.com/ec2/instance-types/)"
  default     = "p3.2xlarge"
}
