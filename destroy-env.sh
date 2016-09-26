#!/bin/bash

launchedInstanceIds="$(aws ec2 describe-instances --query 'Reservations[*].Instances[].InstanceId')"
echo "Instances  $launchedInstanceIds"

autoScalingGroupName="$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].AutoScalingGroupName')"
echo "Auto-scaling-groups  $autoScalingGroupName"

launchConfigurationName="$(aws autoscaling describe-launch-configurations --query 'LaunchConfigurations[0].LaunchConfigurationName')"
echo "launch-configurations  $launchConfigurationName"


loadBalancerNames="$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName')"
echo "load-balancers  $loadBalancerNames"

#Detach load-balancers from autoscaling group
aws autoscaling detach-load-balancers --load-balancer-names $loadBalancerNames --auto-scaling-group-name $autoScalingGroupName

#Delete auto-scaling-group 
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $autoScalingGroupName --force-delete

#Delete launch-configuration
aws autoscaling delete-launch-configuration --launch-configuration-name $launchConfigurationName

#Deregister instances from load-balancer
aws elb deregister-instances-from-load-balancer --load-balancer-name $loadBalancerNames --instances $launchedInstanceIds

#Delete load-balancer listeners 
loadBalancerListeners="$( aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].ListenerDescriptions[*].Listener.InstancePort')"
aws elb delete-load-balancer-listeners --load-balancer-name $loadBalancerNames --load-balancer-ports $loadBalancerListeners

#Delete load-balancer policy -- To be done.

#Delete load-balancer 
aws elb  delete-load-balancer --load-balancer-name $loadBalancerNames

#Terminate instances
aws ec2 terminate-instances --instance-ids $launchedInstanceIds


