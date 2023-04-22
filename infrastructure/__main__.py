import pulumi
from strongmind_deployment.rails import RailsComponent

stack_name = pulumi.get_stack()
component = RailsComponent(stack_name, container_port=80)