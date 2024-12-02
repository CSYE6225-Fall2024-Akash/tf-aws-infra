# tf-aws-infra

This repository contains Terraform configuration files to manage and provision infrastructure as code (IaC). 
This Terraform configuration automates the creation of below resources in AWS: 
1. Create a Virtual Private Cloud (VPC)Links to an external site.
2. Create subnetsLinks to an external site. in your VPC. You must create 3 public subnets and 3 private subnets, each in a different availability zone in the same region in the same VPC. Each of the 3 availability zones must have one public and one private subnet.
3. Create an Internet GatewayLinks to an external site. resource and attach the Internet Gateway to the VPC.
4. Create a public route tableLinks to an external site.. Attach all public subnets created to the route table.
5. Create a private route tableLinks to an external site.. Attach all private subnets created to the route table.
6. Create a public route in the public route table created above with the destination CIDR block 0.0.0.0/0 and the internet gateway created above as the target.

### Prerequisites

Terraform: Ensure Terraform(version 1.9.0 or later is installed). 

Use the below command to check the version.

terraform -v

AWS: Ensure AWS CLI is installed

### AWS Installation & Configuration

Install AWS CLI. 

Refer the below link for setup: link https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Configure the profile using the below command: bash aws configure

Terraform Installation & Configuration

Clone the repository to your local machine using Git. bash git clone <git-url>

Open terminal inside the src/terraform folder of the project directory.

Initialize the working directory with the necessary provider plugins.

terraform init

Create a terraform.tfvars file in the src/terraform folder to configure the variables required for the Terraform configuration: 

editorconfig profile=<your_profile_name> project_name=<your_project_name> vpc_cidr=<cidr_for_the_vpc> vpc_name=<name_of_the_vpc> region=<region_of_the_vpc>

### Running the Configuration

Open terminal inside the src/terraform folder of the project directory.

Run the below command the setup the plan for the resources: bash terraform plan

Run the below command to create the resources: bash terraform apply


### Certification installation

Run the below command from certificate dir to import certificate to AWS:

aws acm import-certificate --certificate fileb://certificate.pem --private-key fileb://private.pem --certificate-chain fileb://certificatechain.pem --region us-east-1
