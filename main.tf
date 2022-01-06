provider "aws" {
  region = var.aws_region
}

provider "random" {}

resource "random_pet" "table_name" {}

resource "aws_dynamodb_table" "tfc_example_table" {
  name = "${var.db_table_name}-${random_pet.table_name.id}"

  read_capacity  = var.db_read_capacity
  write_capacity = var.db_write_capacity
  hash_key       = "UUID"

  attribute {
    name = "UUID"
    type = "S"
  }
}

resource "aws_security_group" "web_server"{
    name = "Allow inbound HTTP/HTTPS/SSH and any outbound"
    
    ingress = [{
        description = "Allow HTTP from anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        self = false
        prefix_list_ids = []
        security_groups = []
    },
    {
        description = "Allow HTTPS from anywhere"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        self = false
        prefix_list_ids = []
        security_groups = []
    },
    {
        description = "Allow SSH from anywhere"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
        self = false
        prefix_list_ids = []
        security_groups = []
    }]

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// Declare the EIP for wordpress site
data "aws_eip" "wordpress_eip" {
    id = "eipalloc-0c4c68616cd40a8de"
}

// Create an instance profile related to the role
resource "aws_iam_instance_profile" "access_s3_profile" {
    name  = "access_s3_profile"
//    role = "${aws_iam_role.ec2_wordpress_role.name}"
    role = "ec2_s3_access_wordpress"
}

// Create an EC2 with a AWS Linux 2 AMI
resource "aws_instance" "EC2" {
    ami = "ami-0ed9277fb7eb570c9"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web_server.name]

    ebs_optimized = false
    root_block_device {
        volume_type = "gp2"
        volume_size = 30
    }
    iam_instance_profile = "${aws_iam_instance_profile.access_s3_profile.name}"
//    user_data = "${file("init.sh")}"
}

resource "aws_eip_association" "eip_association" {
  instance_id   = aws_instance.EC2.id
  allocation_id = data.aws_eip.wordpress_eip.id
}

