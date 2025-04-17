# ssh key
resource "openstack_compute_keypair_v2" "test-keypair" {
  name       = "PC-Matthias"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIEe9HucoQl6jU3VfT7MaZMRcjDxYukkLnv9k5j9o55N matth@PC-Matthias"
}



# Networking
#  Private Network
#   Network
resource "openstack_networking_network_v2" "test-prv-network" {
  name           = "test-prv-network"
  description    = "Test Private Network"
  shared         = false
  external       = false
  admin_state_up = true
}

#   Subnet
resource "openstack_networking_subnet_v2" "test-private_subnet" {
  name            = "test-private-subnet"
  description     = "Test Private Subnet"
  network_id      = openstack_networking_network_v2.test-prv-network.id
  ip_version      = 4
  cidr            = "192.168.1.0/24"
  allocation_pool {
    start         = "192.168.1.100"
    end           = "192.168.1.150"
  }
}


#  Router
#   Test Router
resource "openstack_networking_router_v2" "test-router" {
  name                = "test-router"
  external_network_id = data.openstack_networking_network_v2.ext-floating1.id
}

#     Router Interface
resource "openstack_networking_router_interface_v2" "test-router_interface" {
  router_id = openstack_networking_router_v2.test-router.id
  subnet_id = openstack_networking_subnet_v2.test-private_subnet.id
}


#  Security groups
#   Security Group with ssh, http, https, icmp and Minecraft Access
resource "openstack_networking_secgroup_v2" "test-secgroup" {
  name        = "test-secgroup"
  description = "Allow ssh, http, https, icmp and Minecraft Access"
}

#    SSH Ingress Rule
resource "openstack_networking_secgroup_rule_v2" "ssh-ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.test-secgroup.id
}

#    HTTP Ingress Rule
resource "openstack_networking_secgroup_rule_v2" "http-ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.test-secgroup.id
}

#    HTTPS Ingress Rule
resource "openstack_networking_secgroup_rule_v2" "https-ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.test-secgroup.id
}

#    Minecraft Ingress Rule
resource "openstack_networking_secgroup_rule_v2" "minecraft-ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 25565
  port_range_max    = 25565
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.test-secgroup.id
}

#    icmp ingress rules
resource "openstack_networking_secgroup_rule_v2" "icmp-igress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.test-secgroup.id
}


#  Ports
#   Test Port
resource "openstack_networking_port_v2" "test-port" {
  name               = "test-port"
  description        = "Test Port for VM"
  network_id         = openstack_networking_network_v2.test-prv-network.id
  security_group_ids = [openstack_networking_secgroup_v2.test-secgroup.id]
  admin_state_up     = true
  depends_on = [ openstack_networking_subnet_v2.test-private_subnet ]
}


#  Floating IPs
#   Floating IP for VM
resource "openstack_networking_floatingip_v2" "test-fip" {
  pool = "ext-floating1"
}

#    floating IP association
resource "openstack_networking_floatingip_associate_v2" "test-fip-association" {
  floating_ip = openstack_networking_floatingip_v2.test-fip.fixed_ip
  port_id     = openstack_networking_port_v2.test-port.id
}



# VMs
#  Test VM
resource "openstack_compute_instance_v2" "test-vm" {
  name                    = "test-vm"
  flavor_name             = "a2-ram4-disk20-perf1"
  key_pair                = openstack_compute_keypair_v2.test-keypair.name
  user_data               = file("cloud-init.yaml")
  block_device {
    uuid                  = data.openstack_images_image_v2.Ubuntu-24-04.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 32
    boot_index           = 0
    delete_on_termination = true
  }
  network {
    port                  = openstack_networking_port_v2.test-port.id
  }
}

#   Attach Volume to VM
resource "openstack_compute_volume_attach_v2" "test-vm-volume-server-attach" {
  instance_id = openstack_compute_instance_v2.test-vm.id
  volume_id   = data.openstack_blockstorage_volume_v3.server-volume.id
  device      = "/dev/sdb"
  depends_on  = [openstack_compute_instance_v2.test-vm]
}