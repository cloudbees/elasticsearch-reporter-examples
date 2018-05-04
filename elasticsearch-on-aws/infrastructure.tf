provider "aws" {
  region     = "${var.region}"
}

resource "aws_vpc" "cb_vpc" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "cb_vpc"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet_us_east_1" {
  vpc_id                  = "${aws_vpc.cb_vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, 8, 1)}"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}${var.availability_zone}"
  tags = {
      Name =  "Subnet az 1a"
  }
}

resource "aws_subnet" "private_subnet_us_east_1" {
  vpc_id                  = "${aws_vpc.cb_vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, 8, 2)}"
  availability_zone = "${var.region}${var.availability_zone}"
  tags = {
      Name =  "Subnet private 1 az 1a"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.cb_vpc.id}"
  tags {
        Name = "InternetGateway"
    }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.cb_vpc.main_route_table_id}"
  gateway_id             = "${aws_internet_gateway.gw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_eip" "cb_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.cb_eip.id}"
    subnet_id = "${aws_subnet.public_subnet_us_east_1.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.cb_vpc.id}"

    tags {
        Name = "Private route table"
    }
}

resource "aws_route" "private_route" {
    route_table_id  = "${aws_route_table.private_route_table.id}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

# Associate subnet public_subnet_us_east_1 to public route table
resource "aws_route_table_association" "public_subnet_us_east_1_association" {
    subnet_id = "${aws_subnet.public_subnet_us_east_1.id}"
    route_table_id = "${aws_vpc.cb_vpc.main_route_table_id}"
}

# Associate subnet private_subnet_us_east_1 to private route table
resource "aws_route_table_association" "pr_1_subnet_us_east_1_association" {
    subnet_id = "${aws_subnet.private_subnet_us_east_1.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.cb_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

data "template_file" "gateway_user_data" {
  template = "${file("gateway_user_data.tpl")}"
  vars {
    DISCOVERY = "${join(",", concat(var.gateway_ip_list, var.server_ip_list))}"
  }
}

data "template_file" "server_user_data" {
  template = "${file("server_user_data.tpl")}"

  vars {
    DISCOVERY = "${join(",", concat(var.gateway_ip_list, var.server_ip_list))}"
  }
}

resource "aws_instance" "gateway" {
  count         = "${length(var.gateway_ip_list)}"
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${aws_subnet.private_subnet_us_east_1.id}"
  private_ip    = "${element(var.gateway_ip_list, count.index)}"
  key_name      = "${var.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.allow_all.id}" ]
  user_data     = "${data.template_file.gateway_user_data.rendered}"
  tags {
    Name = "${var.gateway_name}-${count.index}"
    cb-owner = "${var.tag_vm_owner}"
    cb-type = "${var.tag_vm_type}"
  }
}

resource "aws_instance" "data_server" {
  count         = "${length(var.server_ip_list)}"
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${aws_subnet.private_subnet_us_east_1.id}"
  private_ip    = "${element(var.server_ip_list, count.index)}"
  key_name      = "${var.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.allow_all.id}" ]
  user_data     = "${data.template_file.server_user_data.rendered}"
  tags {
    Name = "${var.server_name}-${count.index}"
    cb-owner = "${var.tag_vm_owner}"
    cb-type = "${var.tag_vm_type}"
  }
}

resource "aws_elb" "cb_elb" {
  name            = "cloudbees-es-elb"
  subnets         = [ "${aws_subnet.public_subnet_us_east_1.id}" ]
  security_groups = [ "${aws_security_group.allow_all.id}" ]
  instances       = [ "${aws_instance.gateway.*.id}" ]

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 9200
    instance_protocol = "http"
    lb_port           = 9200
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 5601
    instance_protocol = "http"
    lb_port           = 5601
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    target              = "HTTP:9200/_cluster/health"
  }

  tags {
    Name = "cloudbees-es-terraform-elb"
    cb-owner = "${var.tag_vm_owner}"
    cb-type = "${var.tag_vm_type}"
  }
}

output "cluster_dns" {
  value = "${aws_elb.cb_elb.dns_name}"
}
