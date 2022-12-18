output "lb_addresses" {
  value = [ for task, task_data in var.tasks: {dns_name = module.task[task].lb_dns_name, task = task} ]
}