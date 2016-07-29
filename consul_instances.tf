/**
    file: consul_instances.tf
    description: contains resource declarations for a bastion instance
**/

# Variable `bootstrap_key`, required argument, defines the key to launch the instance with
variable "bootstrap_key" {}

# Variable `private_subnet`, required argument, defines the subnet to launch the instance into
variable "private_subnets" {}

# Variable `security_groups`, required argument, defines security groups to add the instance to
variable "security_groups" {}

# Variable `node_count`, required argument, defines number of instances to launch
variable "node_count" {
    default = 3
}

# Variable `contact`, defaults to `platform@omadahealth.com`, defines the value of the `Contact` tag
variable "contact" {
    default = "platform@omadahealth.com"
}

# Variable `environment`, defaults to `test`, defines the value of the `Environment` tag
variable "environment" {
    default = "test"
}

# Variable `region`, defaults to `us-west-2`, defines the region to launch instances into
variable "region" {
    default = "us-west-2"
}

# Variable `ami_ids`, immutable, defines a hash whose keys are regions and values are AMI IDs
variable "ami_ids" {
    default = {
        us-west-2 = "ami-e106c481"
        us-east-1 = "ami-452bd728"
        eu-west-1 = "ami-ce29babd"
    }
}

# Variable `instance_type`, default `m3.medium`, defines the instance type to launch
variable "instance_type" {
    default = "m3.medium"
}

resource "aws_instance" "consul" {
    count = "${var.node_count}"

    # Instance configuration
    ami           = "${lookup(var.ami_ids, var.region)}"
    instance_type = "${var.instance_type}"
    key_name      = "${var.bootstrap_key}"

    # Networking
    subnet_id                   = "${element(split(",", var.private_subnets), count.index)}"
    vpc_security_group_ids      = ["${split(",", var.security_groups)}"]
    associate_public_ip_address = false

    # House-keeping
    tags {
        Name        = "consul-n${count.index}"
        Environment = "${var.environment}"
        Contact     = "${var.contact}"
        Purpose     = "Consul Service Discovery and KV server"
    }
}

output "consul_private_ips" {
    value = "${join(",", aws_instance.consul.*.private_ip)}"
}

output "consul_instance_ids" {
    value = "${join(",", aws_instance.consul.id)}"
}
