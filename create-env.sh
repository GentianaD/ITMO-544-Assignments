#!/bin/bash

loadBalancerName='itmo544-load-balancer'
aws elb create-load-balancer --load-balancer-name $loadBalancerName --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --security-groups sg-43da1f3a --availability-zones us-west-2b

launchConfigurationName='webserver-config'
aws autoscaling create-launch-configuration --launch-configuration-name $launchConfigurationName --image-id $1 --key-name devenv-key --instance-type t2.micro --user-data file://installapp.sh 
autoScalingGroupName='my-autoscaling-webserver'
aws autoscaling create-auto-scaling-group --auto-scaling-group-name $autoScalingGroupName --launch-configuration-name $launchConfigurationName --availability-zones "us-west-2b" --load-balancer-name $loadBalancerName --max-size 5 --min-size 2 --desired-capacity 4