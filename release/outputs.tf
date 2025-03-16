output "website_url" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.catsanddogs.dns_name
}