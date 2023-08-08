terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "club-devops" {
  image    = "ubuntu-20-04-x64"
  name     = "club-devops"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.terraform.id]
  connection {
    host        = self.ipv4_address
    type        = "ssh"
    user        = "root"
    private_key = file(var.do_key_pair_private_key)
    timeout     = "2m"
  }
}

resource "digitalocean_ssh_key" "terraform" {
  name       = "terraform"
  public_key = file(var.do_key_pair_public_key)
}

