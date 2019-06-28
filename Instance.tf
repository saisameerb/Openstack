provider "openstack" { insecure = true }
# Required parameters per instance
variable "vm-name" { type = "string" }                              # required vm-name
variable "key-pair" { type = "string" }                             # required ssh key pair name
variable "network-name" { type = "string" }                         # name of the private network to attach to
variable "floating-ip-pool" { type = "string" }                     # name of the floating IP pool for public IP

# Optional parameters per instance
variable "image-name" { default = "CENTOS_6.5_VIO-2015.08.12-20G" } # name of the image to use for instances
variable "flavor-name" { default = "m1.medium" }                    # name of the flavor to use, e.g. m1.small
variable "security-groups" { default = ["default","open","base"] }         # names of the security groups to use

# Create a server
resource "openstack_compute_instance_v2" "basic" {
  name = "${var.vm-name}"
  image_name = "${var.image-name}"
  flavor_name = "${var.flavor-name}"
  key_pair = "${var.key-pair}"
  security_groups = "${var.security-groups}"

  network {
    name = "${var.network-name}"
    floating_ip = "${openstack_networking_floatingip_v2.floatip_1.address}"
    access_network = true
  }
}

# Pull floating IP
resource "openstack_networking_floatingip_v2" "floatip_1" {
  pool = "${var.floating-ip-pool}"
}

output "access-ip" { value = "${openstack_compute_instance_v2.basic.network.0.fixed_ip_v4}" }
output "floating-ip" { value = "${openstack_networking_floatingip_v2.floatip_1.address}" }

