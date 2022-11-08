output "panorama_private_ips" {
  value = { for k, v in module.panorama : k => v.panorama_private_ip }
}

output "panorama_public_ips" {
  value = { for k, v in module.panorama : k => v.panorama_public_ip }
}