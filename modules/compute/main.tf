data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["137112412989"] # Amazon
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.ec2_sg_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e

              # Install Python and pip
              yum update -y
              yum install -y python3 git

              # Install virtualenv and Flask
              python3 -m pip install --upgrade pip
              python3 -m pip install flask

              # Create app dir
              mkdir -p /opt/flask_app
              cat > /opt/flask_app/app.py <<'PY'
from flask import Flask, request, jsonify
import datetime
import socket

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():
    timestamp = datetime.datetime.now().astimezone().isoformat()
    visitor_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    host_ip = socket.gethostbyname(socket.gethostname())
    return jsonify({
        "timestamp": timestamp,
        "visitor_ip": visitor_ip,
        "host_ip": host_ip
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PY

              # Create systemd service
              cat > /etc/systemd/system/flask-app.service <<'UNIT'
[Unit]
Description=Flask demo app
After=network.target

[Service]
User=root
WorkingDirectory=/opt/flask_app
ExecStart=/usr/bin/python3 /opt/flask_app/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

              # Start service
              systemctl daemon-reload
              systemctl enable flask-app
              systemctl start flask-app

              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.project_name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 120

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ec2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
