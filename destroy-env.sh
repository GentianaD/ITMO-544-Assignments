#!/bin/bash

autoScalingGroupNames="$(aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[*].AutoScalingGroupName')"
echo "Auto-scaling-groups  $autoScalingGroupNames"

launchConfigurationNames="$(aws autoscaling describe-launch-configurations --query 'LaunchConfigurations[*].LaunchConfigurationName')"
echo "launch-configurations  $launchConfigurationNames"


loadBalancerNames="$(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].LoadBalancerName')"
echo "load-balancers  $loadBalancerNames"

#Loop foreach auto-scaling-group
autoScalingGroupArray=($autoScalingGroupNames)
for i in ${autoScalingGroupArray[@]};
do 
#Detach load-balancers from autoscaling group
 loadBalancerNamesPerAutoScalingGr=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?AutoScalingGroupName=='$i'].LoadBalancerNames[*]");
echo "Detach load-balancers from autoscaling group:  $i";
aws autoscaling detach-load-balancers --load-balancer-names $loadBalancerNamesPerAutoScalingGr --auto-scaling-group-name $i;
#Delete auto-scaling-group 
echo "Delete auto-scaling-group: $i"
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $i --force-delete
 done;

#Loop launch-configuration
launchConfigurationArray=($launchConfigurationNames)
for i in ${launchConfigurationArray[@]};
do 
echo "Deleting launch-configuration:  $i";
 #Delete launch-configuration
aws autoscaling delete-launch-configuration --launch-configuration-name $i
 done;
 


#Loop foreach load-balancer
loadBalancersArray=($loadBalancerNames)

for i in ${loadBalancersArray[@]};
do 

#Deregister instances from load-balancer
 registeredInstancesPerLoadBalancer=$( aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$i'].Instances[*].InstanceId");
 echo "Deregister instances from load-balancer: $i"; 
aws elb deregister-instances-from-load-balancer --load-balancer-name $i --instances $registeredInstancesPerLoadBalancer;

#Delete load-balancer listeners 
loadBalancerListeners=$( aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$i'].ListenerDescriptions[*].Listener.InstancePort");
aws elb delete-load-balancer-listeners --load-balancer-name $i --load-balancer-ports $loadBalancerListeners;

#Delete load-balancer 
aws elb  delete-load-balancer --load-balancer-name $i;

#Terminate instances
aws ec2 terminate-instances --instance-ids $registeredInstancesPerLoadBalancer;
 done;



#Terminate remaining instances
launchedInstanceIds="$(aws ec2 describe-instances --query 'Reservations[*].Instances[].InstanceId')"
echo "Instances  $launchedInstanceIds"
aws ec2 terminate-instances --instance-ids $launchedInstanceIds

echo "destroy-env.sh script finished execution!"
