variable "image" {
  default = "ubuntu-1804-lts"
}
variable "disk" {
  default = "2Gi"
}
variable "public_key" {}
variable "ssh_user" {
  default = "ubuntu"
}
variable "cloud_init" {}

provider "k8s" {
  version                = "~> 0.1"
  host                   = "kubernetes.default.svc"
  token                  = "/var/run/secrets/kubernetes.io/serviceaccount/token"
  cluster_ca_certificate = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
}

resource "k8s_kubevirt.io_v1alpha3_VirtualMachineInstance" "instance" {
  metadata {
     name = var.name
     labels = {
         app = "hobbyfarm-vm"
     }
  }

  spec { 
    terminationGracePeriodSeconds = "30"
    domain {
      resources {
        requests {
          memory = "1024M"
        }
      }
      devices {
        disks {
          name = "containerdisk"
          disk {
            bus = "virtio"
          }
        }
        disks {
          name = "emptydisk"
          disk {
            bus = "virtio"
          }
        }
        disks {
          name = "cloudinitdisk"
          disk {
            bus = "virtio"
          }
        }
      }
    }
    volumes {
      name = "containerdisk"
      containerDisk {
        image = "kubevirt/fedora-cloud-container-disk-demo:latest"
      }
    }
    volumes {
      name = "emptydisk"
      emptyDisk {
        capacity = "2Gi"
      }
    }
    volumes {
      name = "cloudinitdisk"
      cloudInitNoCloud {
        userData = <<EOF
          #cloud-config
          password: fedora
          chpasswd: { expire: False }
          EOF
      }
    }
  } 
}

output "private_ip" {
  value = "${data.k8s_kubevirt.io_v1alpha3_VirtualMachineInstance}"
}

output "public_ip" {
   value = "${data.k8s_kubevirt.io_v1alpha3_VirtualMachineInstance}"
}

output "hostname" {
  value = "${data.k8s_kubevirt.io_v1alpha3_VirtualMachineInstance}"
}
