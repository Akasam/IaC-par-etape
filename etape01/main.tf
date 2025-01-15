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


# Create a Docker container
resource "docker_container" "http" {
  image = docker_image.nginx127.image_id
  name  = "http"
  ports {
    internal = 80
    external = 8080
  }
}

# Pull the nginx image
resource "docker_image" "nginx127" {
  name = "nginx:1.27"
}
