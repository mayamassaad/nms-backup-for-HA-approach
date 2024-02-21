#!/bin/bash

# Define the IP address of the other server
OTHER_SERVER_IP="10.150.209.135"

if ip addr show dev eth0 | grep  10.150.209.138; then
    echo "Keepalived is in MASTER state. Proceeding with the script."

    # Downgrade priority on the current master
    sed -i "s/^\(\s*priority\s*\).*/\150/" /etc/keepalived/keepalived.conf

    # Upgrade priority on the other server
    ssh -i ~/.ssh/id_rsa root@$OTHER_SERVER_IP "sed -i 's/^\(\s*priority\s*\).*/\199/' /etc/keepalived/keepalived.conf"
    ssh -i ~/.ssh/id_rsa root@$OTHER_SERVER_IP "service keepalived restart"

    #Sync the password file
    rsync -e "ssh -i ~/.ssh/id_rsa" --chmod=644 /etc/nms/nginx/.htpasswd root@OTHER_SERVER_IP:/etc/nms/nginx/.htpasswd

    # Restart Keepalived on the current master
    service keepalived restart

    echo "Keepalived roles switched successfully."

    # Send the latest file in /tmp/ starting with "nms" to the other server using SCP
    latest_file=$(ls -1t /tmp/nms* 2>/dev/null | head -n1)
    if [ -n "$latest_file" ]; then
        scp -i ~/.ssh/id_rsa "$latest_file" root@$OTHER_SERVER_IP:/tmp/
        echo "Latest file sent to the other server."
        # Stop services and run restore script on the other server
        ssh -i ~/.ssh/id_rsa root@$OTHER_SERVER_IP << EOF
            systemctl stop nginx
            sudo service nms-core stop
            sudo service nms-dpm stop
            sudo service nms-integrations stop
            cd /etc/nms/scripts
            echo "y" | sudo ./restore.sh /tmp/$(basename "$latest_file")
            sudo service nms-core start
            sudo service nms-dpm start
            sudo service nms-integrations start
            systemctl start nginx
EOF

            echo "Service restoration executed"
    else
        echo "No file found in /tmp/ starting with 'nms'."
    fi

    echo "Script execution completed."

else
    echo "Keepalived is not in MASTER state. Exiting the script."
fi