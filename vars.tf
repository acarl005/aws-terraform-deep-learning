# first do something like `ssh-keygen -t rsa -C youremail@example.org`
# after picking a file path, call ssh-add on the generated private key
# then you'll provide the public key to terraform
variable "public_key_file" {
  description = "file path to RSA public key file, e.g. ~/.ssh/rsa-key.pub (you'll need the associated private key to authenticate via SSH)"
}

variable "volume_size_gb" {
  description = "number of GB of storage for your volume"
  default     = 150
}

variable "instance_type" {
  description = "the type of EC2 instance to run."
  # default     = "p2.xlarge"
  default = "p2.8xlarge"
  # default     = "p3.8xlarge"
  # default = "m3.xlarge"
}

variable "ami" {
  description = "Deep learning AMI to use. Default is Deep Learning AMI (Ubuntu 18.04) Version 28.0. DMXNet-1.6.0, Tensorflow-2.1.0 & 1.15.2, PyTorch-1.4.0, Keras-2.2, & other frameworks, configured with Neuron, NVIDIA CUDA, cuDNN, NCCL, Intel MKL-DNN, Docker & NVIDIA-Docker. Released April 29, 2020"
  default     = "ami-0c5642befe8d041bb"
}