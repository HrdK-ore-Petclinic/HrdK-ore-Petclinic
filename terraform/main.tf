resource "proxmox_virtual_environment_vm" "control_plane" {
  vm_id         = 100
  name          = "k8s-control-plain"
  node_name     = var.proxmox_node_name
  started       = true
  scsi_hardware = "virtio-scsi-single"

  # ignore power state changes to prevent recreation of the VM when it is stopped manually
  lifecycle {
    ignore_changes = [
      started
    ]
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
    units   = 1024
    numa    = false
    limit   = 0
  }

  memory {
    dedicated = 16384
    floating  = 0
    shared    = 0
  }

  disk {
    datastore_id = "local"
    interface    = "ide2"
    size         = 3
    cache        = "none"
    discard      = "ignore"
    iothread     = false
    backup       = true
    replicate    = true
    aio          = "io_uring"
    ssd          = false
    path_in_datastore = "iso/ubuntu-24.04.4-live-server-amd64.iso"
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 100
    file_format  = "qcow2"
    cache        = "none"
    discard      = "on"
    iothread     = true
    backup       = true
    replicate    = true
    aio          = "io_uring"
    ssd          = false
    path_in_datastore = "100/vm-100-disk-0.qcow2"
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
    cores   = 2
    sockets = 1
    type    = "host"
    units   = 1024
    numa    = false
    limit   = 0
  }

  memory {
    dedicated = 8192
    floating  = 0
    shared    = 0
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 60
    file_format  = "qcow2"
    cache        = "none"
    discard      = "on"
    iothread     = true
    backup       = true
    replicate    = true
    aio          = "io_uring"
    ssd          = false
    path_in_datastore = "101/vm-101-disk-0.qcow2"
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
  vm_id     = 102
  name      = "k8s-worker-2"
  node_name = var.proxmox_node_name
  started   = true

  lifecycle {
    ignore_changes = [
      started
    ]
  }
  
  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
    units   = 1024
    numa    = false
    limit   = 0
  }

  memory {
    dedicated = 8192
    floating  = 0
    shared    = 0
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    size         = 40
    file_format  = "qcow2"
    cache        = "writeback"
    discard      = "ignore"
    iothread     = false
    backup       = true
    replicate    = true
    aio          = "io_uring"
    ssd          = false
  }

  network_device {
    bridge      = var.vm_bridge
    model       = "virtio"
    firewall    = true
    enabled     = true
    disconnected = false
    mtu         = 0
    queues      = 0
    rate_limit  = 0
    vlan_id     = 0
    mac_address = "BC:24:11:EC:B9:6F"
  }

  operating_system {
    type = "l26"
  }
}