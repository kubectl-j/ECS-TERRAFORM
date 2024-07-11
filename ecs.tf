# ECS Cluster
resource "aws_ecs_cluster" "nginx_cluster" {
  name = "nginx_cluster"
}

# Task definition for NGINX
resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Public Subnet
data "aws_subnet" "public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["dev-public1"] 
  }
}

# ECS Service
resource "aws_ecs_service" "nginx_service" {
  name            = "nginx_service"
  cluster         = aws_ecs_cluster.nginx_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [data.aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
   depends_on = [aws_security_group.ecs_sg]
}

