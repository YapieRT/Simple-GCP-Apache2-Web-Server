terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

// -------------------Info-------------------

provider "google" {
  credentials = file("<File>.json") // your credentials

  project = "<ID>" // your project id
  region  = "europe-central2"
  zone    = "europe-central2-a"
}

// -------------------Firewall-------------------

resource "google_compute_firewall" "web" {
  name          = "test-firewall"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }
}

// -------------------VM-------------------


resource "google_compute_instance" "vm_instance" {
  name         = "test"
  machine_type = "e2-small"
  zone         = "europe-central2-a"

  tags = ["http-server", "https-server", "test-firewall"]

  boot_disk {
    initialize_params {
      size  = "10"
      image = "ubuntu-2004-focal-v20210720"
    }
  }
  network_interface {
    network = "default"
    access_config {
    }
  }

  // -------------------SSH-------------------

  metadata = {
    ssh-keys = "terraform:${file("<Key>.pub")}" // your user and ssh key
  }

  // -------------------Bash Script-------------------

  metadata_startup_script = file("apache2_install.sh")


  // Doesn`t work, because of host

  /*provisioner "file" {
    source      = "apache2_install.sh"
    destination = "~/apache2_install.sh"
    connection {
      type        = "ssh"
      user        = "terraform"
      private_key = file("~/terraform/terra_test")
      host        = "google_compute_instance.vm_instance.public_ip" 
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/apache2_install.sh",
      "cd ~",
      "./apache2_install.sh"
    ]
    connection {
      type        = "ssh"
      user        = "terraform"
      private_key = file("~/terraform/terra_test")
      host        = "google_compute_instance.vm_instance.public_ip"
    }
  } */


}
