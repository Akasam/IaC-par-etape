terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}
# provider "docker" {
#   host = "unix:///Users/username/.docker/run/docker.sock"
# }

resource "docker_network" "my_network" {
  name = "reseau"
}

resource "docker_container" "c_php" {
  image = docker_image.php83.image_id
  name  = "script"
  networks_advanced {
    name = docker_network.my_network.name
  }
  volumes {
    host_path      = "${path.cwd}/src/index.php"
    container_path = "/var/www/html/index.php"
    read_only      = true
  }
}

resource "docker_container" "c_http" {
  depends_on = [docker_container.c_php]
  image      = docker_image.nginx127.image_id
  name       = "http"
  networks_advanced {
    name = docker_network.my_network.name
  }
  ports {
    internal = 80
    external = 8080
  }
  volumes {
    host_path      = "${path.cwd}/config/default.conf"
    container_path = "/etc/nginx/conf.d/default.conf"
    read_only      = true
  }
  volumes {
    host_path      = "${path.cwd}/src/index.php"
    container_path = "/var/www/html/index.php"
    read_only      = true
  }
}

resource "docker_image" "nginx127" {
  name = "nginx:1.27"
}

resource "docker_image" "php83" {
  name = "php:8.3-fpm"
}
