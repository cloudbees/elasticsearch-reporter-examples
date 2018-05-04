# This file is a collection of data values which control
# how your HA ElasticSearch cluster is deployed. Review all
# values and adjust to suit your needs.

# This is the AWS reagion in which you want to deploy
region             = "us-east-1"

# This identifies the availability zone within the selected region
availability_zone  = "a"

# This is the CIDR block for your VPC. It must be a /16 subnet. Two
# subnets, one for the public facing (master/gateway) VMs and one for
# the private (data server) VMs, each a /8 subnet. Pick carefully,
# but the default below should work for virtually everyone.
vpc_cidr_block     = "172.31.0.0/16"

# The AMI you want to use. It _must_ be an Ubuntu 16.04 AMI, however.
ami                = "ami-cd0f5cb6"

# Obvious, but you probably shouldn't go any smaller than a medium.
instance_type      = "t2.medium"

# These two values are for convenience in finding your ES cluster
# instances in a sea of other instances on the Amazon EC2 Console.
tag_vm_owner       = "dfrye"
tag_vm_type        = "elastic"

# The obvious value
key_name           = "dfrye-test"

# These are the values to assign to the gateway node. The IP is one
# selected from the _internal_ network. The gateway node is the only
# node with an external IP address, as well (allocated/assigned by
# Amazon and not specified in this data file). The gateway nodes store
# no data themselves, but are used only as load balancers between the
# deployed data nodes to create an HA ElasticSearch deployment.
gateway_name       = "test-es-gateway"
gateway_ip_list    = ["172.31.2.10", "172.31.2.11"]

# This is the list of data nodes you want to launch. The number of IP
# addresses from the internal network determine the number of data nodes
# that get created. Each server name is appended with a dash and an
# integer index, starting with zero. The example below launches a total
# of five data nodes, and they are fronted by the gateway nodes above.
# The gateway nodes will load-balance requests across the five data nodes
# deployed.
server_name        = "test-es-server"
server_ip_list     = ["172.31.2.20","172.31.2.21","172.31.2.22", "172.31.2.23", "172.31.2.24"]
