data "vault_kv_secret_v2" "proxmox" {
  mount = "secret"
  name  = "terraform/proxmox"
}

resource "proxmox_virtual_environment_vm" "control_plane" {
  vm_id         = 100
  name          = "k8s-control-plain"
  node_name     = var.proxmox_node_name
  started       = true
  scsi_hardware = "virtio-scsi-single"

  lifecycle {
    ignore_changes = [
      started
    ]
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
    units   = 1024
    numa    = false
    limit   = 0
  }

  memory {
    dedicated = 16384
    floating  = 16384
    shared    = 0
  }

  disk {
    datastore_id      = "local"
    interface         = "ide2"
    size              = 3
    cache             = "none"
    discard           = "ignore"
    iothread          = false
    backup            = true
    replicate         = true
    aio               = "io_uring"
    ssd               = false
    path_in_datastore = "iso/ubuntu-24.04.4-live-server-amd64.iso"
  }

  disk {
    datastore_id      = "zpve-storage"
    interface         = "scsi0"
    size              = 250
    file_format       = "raw"
    cache             = "none"
    discard           = "on"
    iothread          = true
    backup            = true
    replicate         = true
    aio               = "io_uring"
    ssd               = true
    path_in_datastore = "vm-100-disk-0"
  }

  network_device {
    bridge       = var.vm_bridge
    model        = "virtio"
    firewall     = true
    enabled      = true
    disconnected = false
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
    mac_address  = "BC:24:11:6D:8D:7A"
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "worker_1" {
  vm_id         = 101
  name          = "k8s-worker-1"
  node_name     = var.proxmox_node_name
  started       = true
  scsi_hardware = "virtio-scsi-single"

  lifecycle {
    ignore_changes = [
      started
    ]
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
    units   = 1024
    numa    = false
    limit   = 0
  }

  memory {
    dedicated = 16384
    floating  = 16384
    shared    = 0
  }

  disk {
    datastore_id      = "zpve-storage"
    interface         = "scsi0"
    size              = 200
    file_format       = "raw"
    cache             = "none"
    discard           = "on"
    iothread          = true
    backup            = true
    replicate         = true
    aio               = "io_uring"
    ssd               = true
    path_in_datastore = "vm-101-disk-0"
  }

  network_device {
    bridge       = var.vm_bridge
    model        = "virtio"
    firewall     = true
    enabled      = true
    disconnected = false
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
    mac_address  = "BC:24:11:42:A7:F2"
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "worker_2" {
  vm_id         = 102
  name          = "k8s-worker-2"
  node_name     = var.proxmox_node_name
  started       = true
  scsi_hardware = "virtio-scsi-pci"

  lifecycle {
    ignore_changes = [
      started
    ]
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
    units   = 1024
    numa    = false
    limit   = 0
  }

  memory {
    dedicated = 16384
    floating  = 16384
    shared    = 0
  }

  disk {
    datastore_id = "zpve-storage"
    interface    = "scsi0"
    size         = 200
    file_format  = "raw"
    cache        = "writeback"
    discard      = "ignore"
    iothread     = false
    backup       = true
    replicate    = true
    aio          = "io_uring"
    ssd          = true
  }

  network_device {
    bridge       = var.vm_bridge
    model        = "virtio"
    firewall     = true
    enabled      = true
    disconnected = false
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
    mac_address  = "BC:24:11:EC:B9:6F"
  }

  operating_system {
    type = "l26"
  }
}

resource "proxmox_virtual_environment_vm" "worker_3" {
  vm_id               = 103
  name                = "k8s-worker-3"
  node_name           = var.proxmox_node_name
  started             = true
  scsi_hardware       = "virtio-scsi-single"

  lifecycle {
    ignore_changes = [
      started,
      keyboard_layout,
      migrate,
      on_boot,
      reboot,
      reboot_after_update,
      stop_on_destroy,
      timeout_clone,
      timeout_create,
      timeout_migrate,
      timeout_reboot,
      timeout_shutdown_vm,
      timeout_start_vm,
      timeout_stop_vm,
      timeout_move_disk
    ]
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
    units   = 1024
    numa    = false
    limit   = 0
  }

  memory {
    dedicated = 16384
    floating  = 16384
    shared    = 0
  }

  disk {
    datastore_id = "zpve-storage"
    interface    = "scsi0"
    size         = 100
    file_format  = "raw"
    cache        = "none"
    discard      = "on"
    iothread     = true
    backup       = true
    replicate    = true
    aio          = "io_uring"
    ssd          = true
  }

  network_device {
    bridge       = var.vm_bridge
    model        = "virtio"
    firewall     = true
    enabled      = true
    disconnected = false
    mtu          = 0
    queues       = 0
    rate_limit   = 0
    vlan_id      = 0
    mac_address  = "BC:24:11:2F:A3:5D"
  }

  operating_system {
    type = "l26"
  }
}