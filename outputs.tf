output "k8s_master_public_ip" {
    value = yandex_compute_instance.k8s-master01.*.network_interface.0.nat_ip_address[0]
}

output "k8s_worker01_public_ip" {
    value = yandex_compute_instance.k8s-worker01.*.network_interface.0.nat_ip_address[0]
}

output "k8s_worker02_public_ip" {
    value = yandex_compute_instance.k8s-worker02.*.network_interface.0.nat_ip_address[0]
}

resource "local_file" "ansible-inventory" {
  depends_on = [time_sleep.wait_60_seconds]
  content = templatefile("inventory.tftpl", {
    master_ip = "${yandex_compute_instance.k8s-master01.*.network_interface.0.nat_ip_address[0]}"
    worker01_ip = "${yandex_compute_instance.k8s-worker01.*.network_interface.0.nat_ip_address[0]}"
    worker02_ip = "${yandex_compute_instance.k8s-worker02.*.network_interface.0.nat_ip_address[0]}"
  })
  filename = "inventory"
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [
    yandex_compute_instance.k8s-master01,
    yandex_compute_instance.k8s-worker01,
    yandex_compute_instance.k8s-worker02
    ]

  destroy_duration = "60s"
}