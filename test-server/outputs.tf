output "Public-Key-Name" {
  value = openstack_compute_keypair_v2.test-keypair.name
}

output "vm-public-ip" {
  value = openstack_networking_floatingip_v2.test-fip.address
}

output "ssh_command" {
  value = "ssh baumgartmatt@${openstack_networking_floatingip_v2.test-fip.address}"
}