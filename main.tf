terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
 
provider "yandex" {
  token                    = "${var.token}"
  cloud_id                 = "${var.cloud_id}"
  folder_id                = "${var.folder_id}"
  zone                     = "${var.zone}"
}
 

 ######### Network

resource "yandex_vpc_network" "k8s-network" {
    name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s-subnet" {
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.k8s-network.id}"
  v4_cidr_blocks = ["10.0.0.0/24"]
}

########### Disks 

resource "yandex_compute_disk" "k8s-master01-boot-disk" {
    name = "k8s-master01-boot-disk"
    size = 20
    type = "network-hdd"
    zone = var.zone
    image_id = "fd8m8s42796gm6v7sf8e"
}

resource "yandex_compute_disk" "k8s-master01-secondary-disk" {
    name = "k8s-master01-secondary-disk"
    size = 20
    type = "network-hdd"
    zone = var.zone
}

resource "yandex_compute_disk" "k8s-worker01-boot-disk" {
    name = "k8s-worker01-boot-disk"
    size = 20
    type = "network-hdd"
    zone = var.zone
    image_id = "fd8m8s42796gm6v7sf8e"
}

resource "yandex_compute_disk" "k8s-worker02-boot-disk" {
    name = "k8s-worker02-boot-disk"
    size = 20
    type = "network-hdd"
    zone = var.zone
    image_id = "fd8m8s42796gm6v7sf8e"
}


########### Instances

resource "yandex_compute_instance" "k8s-master01" {
  name        = "k8s-master01"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"
  hostname = "k8s-master01"
 
  resources {
    cores  = 4
    memory = 4
    core_fraction = 20
  }
  boot_disk {
      disk_id = yandex_compute_disk.k8s-master01-boot-disk.id
  }
  secondary_disk {
    disk_id = yandex_compute_disk.k8s-master01-secondary-disk.id
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.k8s-subnet.id}"
    nat = true
    ip_address = "10.0.0.3"
    nat_ip_address = "${yandex_vpc_address.k8s-master-public-ip.external_ipv4_address[0].address}"
  }
  metadata = {
    ssh-keys = "${var.user}:${file("id_rsa.pub")}"
  }
  scheduling_policy {
    preemptible = true
  }

}

resource "yandex_compute_instance" "k8s-worker01" {
  name        = "k8s-worker01"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"
  hostname = "k8s-worker01" 

  resources {
    cores  = 4
    memory = 4
    core_fraction = 20
  }
  boot_disk {
      disk_id = yandex_compute_disk.k8s-worker01-boot-disk.id
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.k8s-subnet.id}"
    nat = true
    ip_address = "10.0.0.11"
  }
  metadata = {
    ssh-keys = "${var.user}:${file("id_rsa.pub")}"
  }
  scheduling_policy {
    preemptible = true
  }
}


resource "yandex_compute_instance" "k8s-worker02" {
  name        = "k8s-worker02"
  platform_id = "standard-v2"
  zone        = "ru-central1-a"
  hostname = "k8s-worker02"

  resources {
    cores  = 4
    memory = 4
    core_fraction = 20
  }
  boot_disk {
      disk_id = yandex_compute_disk.k8s-worker02-boot-disk.id
  }
  network_interface {
    subnet_id = "${yandex_vpc_subnet.k8s-subnet.id}"
    nat = true
    ip_address = "10.0.0.12"
  }
  metadata = {
    ssh-keys = "${var.user}:${file("id_rsa.pub")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_vpc_address" "k8s-master-public-ip" {
  name = "k8s-master-public-ip"

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}