### Настройка маскарадинга 

```bash
#cd /etc/sysconfig/iptables
*nat
POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.10.10.0/24 -o enp0s3 -j MASQUERADE
COMMIT
```

```bash
# cd /etc/sysctl.d
# vim 99-sysctl.conf
net.ipv4.ip_forward=1
```

Далее включаем `iptables`

```bash
systemctl enable --now iptables
# далее
sysctl -p
```

### Настрйока сервере 
`cd /etc/sysconfig/network` -- поменять имя устроства на FQDN

`vim /etc/resolvconf.conf` 	-- name_servers=127.0.0.1

```bash
systemctl stop system-resolved
systemctl disable system-resolved
```

Далее ставим самбу

#### Важные моменты в SAMBA
Создание шары и ее автомонтирование на клиентах
После того как мы сделали самбу, нам нужно создать пользователя `smb-mount`, с помощью него мы будем монтировать нашу шару.
Монтирование вручную:

```bash
mount -t cifs //<server-name>.au.team/<наша_шара> /mnt/path/to/dir -o
users,username=smb-mount,password='P@ssw0rd',file_mode=0666,dir_mode=0777
```

Чтобы сделать это через `/etc/fstab`

```bash
# /etc/fstab
//srv.au.team/sambashare/ /srv/sambasha cifs username=smb-mount,password=P@ssw0rd,file_mode=0666,dir_mode=0777,_netdev 0 0
```

Сама шара описывается в smb.conf

```ini
[shara]
	path = /<path>
	read only = no
	writable = yes
	browseable = yes
	guest ok = yes
	create mask = 0666
	directory mask = 0777








