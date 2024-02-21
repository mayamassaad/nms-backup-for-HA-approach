NMS (Nginx Managment Suite)
This is the backup script provided by the nms (https://docs.nginx.com/nginx-management-suite/admin-guides/maintenance/backup-and-recovery/)
The scripts in a nms are located in /etc/nms/scripts.
We added the keepalived and added a VIP for both server.
We have configured a backup script to run every Friday at 12pm, storing all backups in the /tmp directory. Five minutes after the initial backup, a secondary script is executed. This script “update-backups.sh” helps maintain a limit of five backup packages in both the /tmp and /master directories. However, the number of these packages can be increased, which we will discuss in the next section. Additionally, we have an update-backup script that aids the master server in sending a copy of the backup package to a secondary server, referred to as the backup server. This ensures that we do not have a single point of failure in case the master server becomes unreachable.

 "crontab -l
0 12 * * 5 cd /etc/nms/scripts/ && ./backup.sh
5 12 * * 5 cd /tmp/ && ./update-backups.sh"


I created a script updates-backups.sh This script is specifically created to delete the obsolete backups files from both folders /tmp and /tmp/master. In addition, it sends the new nms-backup to the backup instance.



 For the automated backup scripted "called switch_master_restore.sh"
 I have created a script for failover between two nms instances. As nim does not have HA approach, we tried created a script that do a pseudo-HA, where the user should activate the script in order to have a complete failover method.

This bash script is designed to be executed in a scenario where the Keepalived service is running on two servers in a High Availability (HA) configuration. Keepalived is a tool commonly used for setting up high availability for Linux systems, and it works by allowing multiple servers to share an IP address and ensure that one server takes over in case the other fails. The script is structured to run on the server currently in the MASTER state according to Keepalived.

 
