#!/bin/bash
if [$#<5]
 then
 echo "You need to provide 5 parameters: ami-id key-name security-group launch-configuration count "
else

loadBalancerName='itmo544-load-balancer'
aws elb create-load-balancer --load-balancer-name $loadBalancerName --listeners "Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80" --security-groups $3 --availability-zones us-west-2b

launchConfigurationName=$4
aws autoscaling create-launch-configuration --launch-configuration-name $launchConfigurationName --image-id $1 --key-name $2 --instance-type t2.micro --user-data file://installapp.sh 
autoScalingGroupName='my-autoscaling-webserver'

aws autoscaling create-auto-scaling-group --auto-scaling-group-name $autoScalingGroupName --launch-configuration-name $launchConfigurationName --availability-zones "us-west-2b" --load-balancer-name $loadBalancerName --max-size 5 --min-size 2 --desired-capacity 4

echo "create-env.sh script finished execution!"
fi 