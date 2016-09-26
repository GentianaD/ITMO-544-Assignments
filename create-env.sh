#!/bin/bash

aws ec2 run-instances --image-id ami-06b94666 --key-name devenv-key --security-group-id sg-43da1f3a --instance-type t2.micro --user-data file://installapp.sh --count $1 --placement AvailabilityZone=us-west-2b
launchedInstanceIds="$(aws ec2 describe-instances --query 'Reservations[*].Instances[].InstanceId')"
loadBalancerName='itmo544-load-balancer'
aws ec2 wait instance-running --instance-ids $launchedInstanceIds
aws elb create-load-balancer --load-balancer-name $loadBalancerName --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --security-groups sg-43da1f3a --availability-zones us-west-2b

aws elb register-instances-with-load-balancer --load-balancer-name $loadBalancerName --instances $launchedInstanceIds
launchConfigurationName='webserver-config'
aws autoscaling create-launch-configuration --launch-configuration-name $launchConfigurationName --image-id ami-06b94666 --key-name devenv-key --instance-type t2.micro --user-data file://installapp.sh 
autoScalingGroupName='my-autoscaling-webserver'
aws autoscaling create-auto-scaling-group --auto-scaling-group-name $autoScalingGroupName --launch-configuration-name $launchConfigurationName --availability-zones "us-west-2b" --load-balancer-name $loadBalancerName --max-size 5 --min-size 2 --desired-capacity 4