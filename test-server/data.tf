data "openstack_networking_network_v2" "ext-floating1" {
  name = "ext-floating1"
}

data "openstack_images_image_v2" "Ubuntu-24-04" {
  name = "Ubuntu 24.04 LTS Noble Numbat"
}

data "openstack_blockstorage_volume_v3" "server-volume" {
  name = "server-volume"
}