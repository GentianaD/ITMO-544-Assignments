#!/bin/bash
echo "Hello" > hello.txt
sudo apt-get update -y
sudo apt-get install -y apache2
sudo apt-get install -y git-all


sudo systemctl enable apache2
sudo systemctl start apache2
while true
do
if [ -d "/var/www/html" ]; then
    sudo rm /var/www/html/index.html
    sudo git clone https://github.com/GentianaD/itmo544_website/ /var/www/html
    break
fi
done