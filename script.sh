#!/bin/bash


# test for root permissions
clear
if [ $UID != '0' ]
    then
    echo run the script with root permissions!
    exit
fi

# questions just to make sure
echo -n 'Did you read the README? (Y/N):'
read answer
if [ $answer = 'n' ]
    then
    echo 'Read the README!'
    exit
fi
if [ $answer = 'N' ]
    then
    echo 'Read the README!'
    exit
fi

echo -n 'Did you answer the forensics questions? (Y/N):'
read answer
if [ $answer = 'n' ]
    then
    echo 'Answer the forensics questions!'
    exit
fi
if [ $answer = 'N' ]
    then
    echo 'Answer the forensics questions!'
    exit
fi

# creating backups
cp /etc/lightdm/lightdm.conf ~/cyberpatriot/backups
cp /etc/pam.d/common-password ~/cyberpatriot/backups
cp /etc/logon.defs ~/cyberpatriot/backups
cp /etc/pam.d/common-auth ~/cyberpatriot/backups
cp /etc/auditd.auditd.conf ~/cyberpatriot/backups
cp /etc/group ~/cyberpatriot/backups
cp /etc/passwd ~/cyberpatriot/backups
echo backups created!

# policies
chmod 777 /etc/lightdm/lightdm.conf
echo disabling guest account...
echo allow-guest=false >> /etc/lightdm/lightdm.conf
echo guest account disabled!
chmod 644 /etc/lightdm/lightdm.conf

chmod 777 /etc/pam.d/common-password
echo changing password policies...
apt-get -y install libpam-cracklib
echo add pam_unix.so remember=5 minlen=8 and pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
gedit /etc/pam.d/common-password
#sed  -i 's/pam_unix.so.*/pam_unix.so remember=5 minlen=8/g' /etc/pam.d/common-password
#sed  -i 's/pam_cracklib.so.*/pam_cracklib.so ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/g' /etc/pam.d/common-password
echo password policies updated!
chmod 644 /etc/pam.d/common-password

chmod 777 /etc/logon.defs
echo changing password aging...
sed -i s/PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/g /etc/logon.defs
echo password aging fixed!
chmod 644 /etc/logon.defs

chmod 777 /etc/pam.d/common-auth
/etc/logon.defs
echo changing account policy...
echo auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800 >> /etc/pam.d/common-auth
echo account policy updated!
chmod 644 /etc/pam.d/common-auth

echo enabling audits...
apt-get -y install auditd
auditctl -e 1
chmod 777 /etc/audit/auditd.conf
echo '#
# This file controls the configuration of the audit daemon
#
local_events = yes
log_file = /var/log/audit/audit.log
write_logs = yes
log_format = RAW
log_group = root
priority_boost = 4
flush = INCREMENTAL_ASYNC
##freq = 20
num_logs = 5
disp_qos = lossy
dispatcher = /sbin/audispd
name_format = NONE
##name = mydomain
max_log_file = 6
max_log_file_action = ROTATE
space_left = 75
space_left_action = SYSLOG
action_mail_acct = root
admin_space_left = 50
admin_space_left_action = SUSPEND
disk_full_action = SUSPEND
disk_error_action = SUSPEND
##tcp_listen_port =
tcp_listen_queue = 5
tcp_max_per_addr = 1
##tcp_client_ports = 1024-65535
tcp_client_max_idle = 0
enable_krb5 = no
krb5_principal = auditd
##krb5_key_file = /etc/audit/audit.key' > /etc/audit/auditd.conf
echo audits enabled!
chmod 644 /etc/audit/auditd.conf

# create list of files under the user directory
ls /home -R > script_user_file_list.txt

clear
# find media files
echo "txt files located in user directory:"
echo -------------------------------------------------------------------
grep ".txt" script_user_file_list.txt
echo ""
echo "mp3 files located in the user directory:"
echo -------------------------------------------------------------------
grep ".mp3" script_user_file_list.txt
echo ""

echo -n Continue...
read

#other
apt-get install ufw
ufw enable
ufw deny 1337
echo firewall enabled!

sudo apt-get remove pure-ftpd
sudo apt-get remove samba
sudo apt-get remove zenmap nmap
echo nospoof on >> /etc/host.conf

service --status-all >> ~/cyberpatriot/services.txt

chmod 604 /etc/shadow
chmod 640 .bash_history

echo updating...
apt-get -y update
apt-get -y upgrade
echo updates complete!


echo services....?
apt-get install bum
bum
echo -n Continue...
read

exit
