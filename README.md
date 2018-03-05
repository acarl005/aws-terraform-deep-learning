# AWS Deep Learning AMI with Terraform

Get a beefy GPU in AWS quickly.

## Why you're here

Because you want to train some deep learning models and you need an instance in AWS with a powerful GPU (possibly with a Jupyter Notebook).
However, you don't want the frustration of setting up security groups, VPCs, routing tables, subnets, installing libraries, etc.
This setup should be as automated as possible so scientists and engineers can get working on models quickly.
Using Terraform, I'm trying to get this setup as automated as possible.
This module will spin up a `p3.2xlarge` in EC2 on the [Deep Learning AMI](https://aws.amazon.com/marketplace/pp/B077GCH38C).

## Setup

**WARNING: Never, ever copy any AWS credentials into source-controlled repositories. Someone will steal then and mine a bunch of Bitcoin on your dime!**

1. Download [Terraform](https://www.terraform.io/downloads.html).
1. Obtain an AWS key and secret and place in `~/.aws/credentials` under the `[terraform]` profile. Make sure the account has permissions for EC2, EBS, etc.
    ```
    [terraform]
    aws_access_key_id = <your_key_id>
    aws_secret_access_key = <your_access_key>
    ```
1. Create an SSH key pair with `ssh-keygen` and add the private key with `ssh-add`.
    ```sh
    ssh-keygen -t rsa -C "email@example.org" -f ~/.ssh/example_name
    ssh-add ~/.ssh/example_name
    ```
1. Go into the `terraform` directory and run `terraform init` and `terraform apply`. You will be prompted to provide the location of your newly generated public SSH key (you can put this in a `terraform.tfvars` instead).
1. When the command is done, assuming you have the correct permissions and such, you should see some output like the public IP addr and DNS name for the newly created instance.
1. Get the address and try logging in via SSH `ssh ubuntu@your-elastic-ip`
1. Mount the EBS Volume with [these instructions](https://devopscube.com/mount-ebs-volume-ec2-instance/). Keep in mind the device location in `/dev` will probably be different than in that tutorial.
1. Copy the files to the instance.
1. Activate the Conda environment you want. For example, if you want TensorFlow on Python 3.6: `. ~/anaconda3/bin/activate tensorflow_p36`
1. Run Jupyter `jupyter notebook --ip=* --no-browser`. Get the token.
1. Visit your browser at `your-elastic-ip:8888/?token=<your-token-here>`.


## Contribute!

There are surely some improvements to be made. More to be automated, better security, better documentation.
If you're feeling generous, please leave a PR with improvements or at least as issue with some helpful advice.
