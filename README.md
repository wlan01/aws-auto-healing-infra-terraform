# aws-auto-healing-infra-terraform

- Modular Terraform code (modules: `vpc`, `security`, `alb`, `compute`, `monitoring`)
- Flask app bootstrapped via EC2 user-data and run as a systemd service
- ALB health checks driving ASG replacements (auto-healing)
- CloudWatch alarms + autoscaling policies (scale out / scale in)
