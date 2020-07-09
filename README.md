# Deep Learning Research Setup with Terraform

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
2. Storage is kept in EFS, mounted at `/efs`. Store data, code, etc here 
3. Activate the Conda environment you want. For example, if you want TensorFlow on Python 3.6: `. ~/anaconda3/bin/activate tensorflow_p36`
4. Run Jupyter `jupyter notebook --ip=* --no-browser`. Get the token.
5. Visit your browser at `your-elastic-ip:8888/?token=<your-token-here>`.

## notes

**Low Cost**
- The guiding principle is *pay only for what you need* (and as few AWS charges as possible). Thus, we use EFS instead of EBS - it works across instances, and there's a lower upfront cost. If you terminate your instance, all you have to pay for is what you actually store

**Flexibility**
- The one drawback I've found is that there's no fine-grained control for stopping and starting instances with Terraform. This repo is great for spinning up an instance and then SSH-ing into it.

**Spot Instances**
- So far, no support for spot instances. I'd be super interested if there were a command you can run, which would set up perhaps fleets of stuff.
- Ephemeral instances work great with the shared storage on EFS: If an instance shuts down, it keeps the files (checkpoints, data, etc) in EFS!


## Contribute!

There are surely some improvements to be made. More to be automated, better security, better documentation.
If you're feeling generous, please leave a PR with improvements or at least as issue with some helpful advice.
