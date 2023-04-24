import os
import pulumi
from strongmind_deployment.rails import RailsComponent

stack_name = pulumi.get_stack()
container_image = os.environ['CONTAINER_IMAGE']
component = RailsComponent(stack_name,
                           container_port=3000,
                           container_image=container_image)