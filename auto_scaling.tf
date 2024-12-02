resource "aws_autoscaling_group" "webapp" {
  name                      = "${var.environment}-webapp-asg"
  desired_capacity          = 3
  max_size                  = 5
  min_size                  = 3
  target_group_arns         = [aws_lb_target_group.webapp.arn]
  vpc_zone_identifier       = [aws_subnet.public[0].id]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown          = 60

  launch_template {
    id      = aws_launch_template.webapp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-webapp-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "webapp-scale-up"
  autoscaling_group_name = aws_autoscaling_group.webapp.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "webapp-scale-down"
  autoscaling_group_name = aws_autoscaling_group.webapp.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

# CloudWatch Alarm for Scale Up
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "webapp-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 12

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp.name
  }

  alarm_description = "Scale up if CPU > 5%"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

# CloudWatch Alarm for Scale Down
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "webapp-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 8

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp.name
  }

  alarm_description = "Scale down if CPU < 3%"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}