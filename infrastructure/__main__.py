import os
import pulumi
from strongmind_deployment.rails import RailsComponent

master_key = os.environ['RAILS_MASTER_KEY']

stack_name = pulumi.get_stack()
container_image = os.environ['CONTAINER_IMAGE']
component = RailsComponent(stack_name,
                           container_port=3000,
                           container_image=container_image,
                           env_vars={
                               'RAILS_MASTER_KEY': master_key,
                           })