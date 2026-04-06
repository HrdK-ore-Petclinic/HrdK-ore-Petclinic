output "control_plane_name" {
  description = "name of control-plain"
  value       = proxmox_virtual_environment_vm.control_plane.name
}

output "worker_1_name" {
  description = "name of worker 1"
  value       = proxmox_virtual_environment_vm.worker_1.name
}

output "worker_2_name" {
  description = "name of worker 2"
  value       = proxmox_virtual_environment_vm.worker_2.name
}