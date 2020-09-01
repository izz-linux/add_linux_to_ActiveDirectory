#!/bin/bash

yum -y install krb5-workstation samba-common-tools sssd-ad

cat > /etc/krb5.conf <<EOF
[logging]
 default = FILE:/var/log/krb5libs.log

[libdefaults]
 default_realm = RXBENEFITS.LOCAL
 dns_lookup_realm = true
 dns_lookup_kdc = true
 ticket_lifetime = 24h
 renew_lifetime = 7d
 rdns = false
 forwardable = yes
EOF

cat > /etc/samba/smb.conf <<EOF
[global]
   workgroup = RXLOCAL
   client signing = yes
   client use spnego = yes
   kerberos method = secrets and keytab
   log file = /var/log/samba/%m.log
   password server = RXBENEFITS.LOCAL
   realm = RXBENEFITS.LOCAL
   security = ads
EOF

echo 'thisWOULDbeMyPassword(butItIsNot)' | kinit damnoland

net ads join -k

yum -y install oddjob-mkhomedir
authconfig --update --enablesssd --enablesssdauth --enablemkhomedir

cat > /etc/sssd/sssd.conf <<EOF
[sssd]
 config_file_version = 2
 domains = rxbenefits.local
 services = nss, pam, pac

[domain/RXBENEFITS.LOCAL]
 id_provider = ad
 auth_provider = ad
 chpass_provider = ad
 access_provider = simple
 simple_allow_groups = rxblinuxadmins
 override_homedir = /home/%u
 default_shell = /bin/bash 
EOF

chmod 600 /etc/sssd/sssd.conf
systemctl restart sssd

echo '%RxBLinuxAdmins ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

