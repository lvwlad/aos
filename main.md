<img width="995" height="840" alt="изображение" src="https://github.com/user-attachments/assets/c0be28c0-0011-40b5-9287-813ddd0215c1" />



| Имя ВМ   | IP-адрес                                                                                                                       |
| -------- | ------------------------------------------------------------------------------------------------------------------------------ |
| RTR-L    | Сети internet адрес прилетает по DHCP<br>10.10.10.1/24 – для подсети офиса L-RTR<br>20.20.20.1/24 – для подсети офиса ADMIN-PC |
| L-SRV    | 10.10.10.100/24                                                                                                                |
| ADMIN-PC | 20.20.20.150/24                                                                                                                |
| CLI      | DHCP                                                                                                                           |
1. Настройте сервер DHCP на базе RTR-L.
	a. Создайте два пула для серверов (10.10.10.100-10.10.10.120) и клиентских пк
	(20.20.20.150-20.20.20.200)
	b. Зарезервируйте выданный ip адрес серверу L-SRV
	c. Адрес шлюза по умолчанию - адреса маршрутизаторов RTR-L
2. Настройте доменный контроллер Samba на машине L-SRV. Имя домена au.team.
	a. Создайте 50 пользователей для офиса left (группа left), имена пользователей
	формата user№.userl.
	b. Пользователи группы left и admin имеют право аутентифицироваться на
	любом клиентском ПК (ADMIN-PC и CLI).
	c. Пользователи группы left должны иметь возможность повышать привилегии
	для выполнения ограниченного набора команд: cat
	d. Пользователи группы admin должны иметь возможность повышать
	привилегии без ввода пароля.
	e. Для всех пользователей домена должны быть реализованы общие каталоги
	по пути /mnt/sharesamba. Должно происходить автомонтирование
	f. Введите клинские машины в домен
3. Настройка DNS для офиса left.
	a. Основной DNS-сервер реализован на доменном контроллере.
	b. Для всех устройств используется доменное имя au.team.
	c. Для всех устройств необходимо создать записи A.
	d. В качестве DNS сервера пересылки используйте сервера 94.232.137.104
4. На srv-l установите NFS сервер
	a. На диске sdb создайте таблицу разделов типа GPT. Создайте один основной
	раздел, занимающий весь объем диска (sdb1).
	b. Отформатируйте его в файловую систему xfs.
	c. Создайте директорию /srv/nfsshare и перемонтируйте туда диск sdb1
	обеспечьте что бы диск подключался автоматический.
	d. Добавьте авто монтирование на ADMIN-PC NFS шары по доменному имени
	в директорию /mnt/nfs
	
5. Автоматизация с Ansible с динамическим инвентарем и шифрованием
	a. Создать 2 плейбуков:
		i. playbook_mount_nfs.yml — автоматическое монтирование
		/srv/nfsshare на /mnt/share на CLI.
		ii. playbook_unmount_nfs.yml — отключение монтирования и удаление
		временных файлов.
	b. Плейбук для монтирования:
		i. Примонтируйте шару.
		ii. Включите автозагрузку через fstab.
	c. Плейбук для отключения:
		i. Отмонтируйте шару.
		ii. Удалите точки монтирования.
6. Настройка удаленного доступа
	a. Установите remina на машину администратора
	b. По средствам xrdp предоставите пользователю remote возможность
	подключение с компьютера ADMIN-PC к CLI
7. Универсальный калькулятор с валидацией и логированием
	Создайте скрипт на ADMIN-PC по пути /home/calc.sh, который обрабатывает
	параметры командной строки, выполняет математические операции, валидирует
	данные и логирует ошибки

#### Настройка ip-адресов 
Через `nmcli` ⬇️
Статичный:
```bash
nmcli con add type ethernet con-name <имя_соединения> ifname <имя_интерфейса> ipv4 <адрес> ipv4.gateway <ip-шлюза> 
```
DHCP:
```bash
nmcli con add type ethernet con-name <имя_соединения> ifname <имя_интерфейса> ipv4.method auto
```

Через `etcnet`⬇️

```bash
cd /etc/net/iface/<имя_интерфейса>
```

```bash
# ну тут корчое файлы ipv4address ipv4route и options
```

```bash
# пример ipv4address
10.10.10.1/24
```

```bash
# пример ipv4route
defaul via 10.10.10.1
```
и т.д.

####  1) Настройка DHCP-server
```bash
apt-get update
apt-get install -y dhcp-server
```

Укажем системе на каких интерфейсах работает DHCP-server
```bash
vim /etc/sysconfig/dhcpd
```

Далее изменим значение у переменно `DHCPARGS`, указав через пробел в кавычках необходимые интерфейсы.
```bash
#/etc/sysconfig/dhcpd

DHCPARGS="enp0s8 enp0s9"
# enp0s8,enp0s9 - интерфейсы
```

После перейдем в настройку самого DHCP-сервера.
перейдем в `/etc/dhcp`
```bash
[root@host-15 sysconfig]# cd /etc/dhcp/
[root@host-15 dhcp]# ll
итого 28
drwxr-xr-x 154 root root 12288 фев  2 20:51 ../
drwxr-xr-x   2 root root  4096 фев  2 20:50 ./
-rw-------   1 root root  3282 фев  2 20:50 dhcpd6.conf.sample
-rw-r--r--   1 root root  3266 фев  2 20:50 dhcpd.conf.example
-rw-------   1 root root   396 фев  2 20:50 dhcpd.conf.sample
```

Скопируем `dhcpd.conf.example` с именем `dhcpd.conf`
```bash
cp dhcpd.conf.example dhcpd.conf
```


Настроим DHCP-сервер 

```bash
# /etc/dhcp/dhcpd.conf

option domain-name "au.team";
option domain-name-servers 10.10.10.100, 8.8.8.8;

default-lease-time 6000;
max-lease-time 7200;

authoritative;
# пул адресов
subnet 10.10.10.0 netmask 255.255.255.0 {
  range 10.10.10.100 10.10.10.120;
  option routers 10.10.10.1;
}
# пул адресов
subnet 20.20.20.0 netmask 255.255.255.0 {
  range 20.20.20.150 20.20.20.200;
  option routers 20.20.20.1;
}
# резер адреса
host l-srv {
  hardware ethernet 08:00:27:a5:b1:72;
  fixed-address 10.10.10.100;
}
host admin-pc {
  hardware ethernet 08:00:27:a5:b1:72;
  fixed-address 20.20.20.150;
}

```

❗❗❗ВОЗМОЖНЫЕ ОШИБКИ

В `/etc/resolvconf.conf` поменять адрес сервера, так как на основе этого файла генерируется /etc/resolv.conf

```bash
resolv_conf_options='edns0 trust-ad'
name_servers=127.0.0.1
```
Здесь мы отрубаем встроенный DNS-сервер (127.0.0.53)

---

необходимо закомментить настройку (хз, так-то можно и оставить) и поменять имя сервера на адрес в локальной сети.
```bash
#resolv_conf_options='edns0 trust-ad'
name_servers=10.10.10.100
```

В `/etc/net/iface/<интерфейс>/option` указать имя хоста
```bash
# /etc/net/iface/<интерфейс>/option
...
NAMESERVER=10.10.10.100
```


В итоге на сервере файл `/etc/resolv.conf` должен выглядеть следующим образом:

```bash
domain au.team
nameserver 10.10.10.100
nameserver 8.8.8.8 # у меня 8.8.8.8, а так надо тот, который будет указан по заданию
```

####  2) Настройка SambaAD 
на сервере:

Сначала установим необходимые пакеты
```bash
apt-get update
apt-get install samba samba-dc krb5-workstation
```

так же исправим на всякий случай файл /etc/hosts, который позволяет сопоставить адрес с именем. Данный файл имеет приоритет выше, чем DNS, позволяя перенаправлять трафик.
```bash
# /etc/hosts
# первая записть локаьная, ее оставляем 
# добавляем следующую 
10.10.10.100 l-srv.au.team l-srv
```

⁉️ На сервере (Alt-Server) какая-то хуйня с адресами серверов в резолвере. поэтому перейдем в `/etc/systemd/resolved.conf`
```bash
# `/etc/systemd/resolved.conf`
[Resolve]
DNSStubListener=no
```


Также проверим имя хоста в файле `/etc/sysconfig/network`
Должно быть:
```bash
HOSTANME=l-srv.au.team # указываем полное доменное имя
```

Далее необходимо остановить все конфликтующие службы 
```bash
systemctl stop krb4kdc named slapd bind dnsmasq smb nmb
systemctl disable krb4kdc named slapd bind dnsmasq smb nmb
```

Перед созданием домена необходимо очистить старые конфигурации.
```bash
rm -f /etc/samba/smb.conf
rm -rf /var/lib/samba
rm -rf /var/cache/samba
mkdir -p /var/lib/samba/sysvol
```

Далее разворачиваем сам AD
```bash
samba-tool domain provision --realm=AU.TEAM \
 --domain=AU \
 --adminpass='P@ssw0rd' \
 --dns-backend=SAMBA_INTERNAL \
 --option='dns forwarder=8.8.8.8' \ # тут указываем тот, что по заданию
 --server-role=dc
 --use-rfc2307 # если нужен по заданию 
```

После запустим сервис
```bash
systemctl enable --now samba.service
```

Далее необходимо заменить шаблон файла krb5.conf, который сгенерировался автоматически в каталог `/var/lib/samba/private` 
```bash
mv /etc/krb5.conf /etc/krb5.conf.default # сохраняем старый 
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf  # заменяем
```

После успешного создания домена проверим настройку домена
```bash
samba-tool domain info 10.10.10.100
```

###### a) создание пользователей в группе left
создаем группу 
```bash
samba-tool group add left
samba-tool group add admin
```
Напишем скрипт для создания пользователей 
```bash
#!/bin/bash
# 
for i in {1..50}; do
	user="user$i.userl"
	samba-tool user add $user P@ssw0rd
	samba-tool group addmembers left $user
	# echo "$user created"
done 
```
###### b) вход на любой ПК

На `CLI` и `ADMIN-PC` необходимо установить пакет `task-auth-ad-sssd`
```bash
apt-get update && apt-get install -y task-auth-ad-sssd
```
Теперь доменные пользователи могут войти в систему 
###### c) повышение привилегий для ограниченного набора команд группы left
пока предположительно 
Смотреть примеры заполнения прав в `visudo`
```bash
visudo
```
Далее перейдем в `/etc/sudoers.d`
Создадим два файла для наших групп (❗ пока не разобрался, это не работает)
```bash
echo "%AU\left ALL=(ALL) /bin/cat" > left
echo "%AU\admin ALL=(ALL) ALL" > admin
```
вроде это все.

###### e) общая папка samba по пути /mnt/sharesamba

создаем папку 
```bash
mkdir -p /mnt/sharesamba
```
Далее переходим в конфиг самбы `/etc/samba/smb.conf`
```bash
# здесь необходимо добавить секцию с нашей папкой
[sharesamba] # имя может быть любым 
	path = /mnt/sharesamba
	read only = No
	writable =Yes
	guest ok = Yes
	create mask = 0666
	dirictory mask = 0777
	# valid users = user1 user2 и тд
```
Далее перезапускаем самбу 
```bash
systemctl restart samba
```

и все

###### f) вводим тачки в домен
на клиентах 
```bash
acc
```
Далее пользователи -> аутентификация 
![[Pasted image 20260203225148.png]]



#### 3) Настройка DNS для офиса left

После добавления компьютеров в домен, A-записи автоматически добавляются в зону прямого просмотра 
Чтобы посмотреть список зон выполним команду
```bash
samba-tool dns zonelist 10.10.10.100 -U Administrator
# указывать пользователя через опцию -U обязательно
```

В выводе будут указаны все зоны.

Далее мы можем запросить записи зоны:
```bash
samba-tool dns query 10.10.10.100 au.team @ ALL -U Administrator
# здесь au.team - это имя зоны, @ - вместо домена (спец. символ, можно указать сам домен), ALL - вывести все записи
```

######  c) создаем PTR-запись
Чтобы создать такие записи, необходимо создать зону обратного просмотра
```bash
samba-tool dns zonecreate 10.10.10.100 10.10.10.in-addr.arpa -U Administrator
samba-tool dns zonecreate 10.10.10.100 20.20.20.in-addr.arpa -U Administrator
```

Теперь добавим записи в эти зоны.
```bash
samba-tool dns add 10.10.10.100 10.10.10.in-addr.arpa 100 PTR l-srv.au.team -u Administrator
samba-tool dns add 10.10.10.100 20.20.20.in-addr.arpa 150 PTR l-srv.au.team -u Administrator
```

#### 4) NFS-сервер на l-srv
###### a-b) создание GPT-таблицы на диске sdb1
```bash
gparted
```
далее перейти в устройства -> создать раздел -> gpt
далее создаем раздел с типом ФС `xfs`

###### c)
создадим точку монтирования для диска
```bash
mkdor -p /srv/nfsshare

```

посмотрим UUID диска 
```bash
blkid
```

далее перейдем в конфиг 
```bash
vim /etc/fstab
```

добавим запись о новом разделе
```bash
# /etc/fstab

UUID=<UUID раздела sdb1>  <точка монтирования> <тип файловой системы> defaults 0 0
```

###### d) установка NFS-сервера 
Для запуска и работы NFS необходимы следующие пакеты:
```bash
apt-get install -y nfs-server nfs-clients rpcbind
# на AltServer они должны быть установлены по умолчанию
```
далее необходимо запустить все необходимые службы
```bash
control rpcbind server
systemctl enable --now nfs
```
Теперь перейдем непосредственно к созданию NFS-шары
На сервере перейдем в `/etc/exports` (в этом файле описываются шары)
В нем опишем нашу шару
```bash
# /etc/exports
# path host|network(options) - общий вид записи 

/srv/nfsshare    20.20.20.0/24(rw,:wqno_subtree_check) 
```
теперь необходимо применить изменения, записанные в /etc/exports
для этого используем следующую команду
```bash
exportfs -va
```
Далее перезапустим сервер 
```bash
systemctl enable --now nfs
# systemctl restart nfs
```

Теперь перейдем на ADMIN-PC
Проверим наличие наших папок 
```bash
showmount -e l-srv.au.team
```

Далее перейдем в `/etc/fstab`
```bash
# /etc/fstab
# добавим запись 
l-srv.au.team:/srv/hfsshare /mnt/nfs nfs defaults 0 0 
```
```bash
# перезапускаем клиента 
reboot
```
Далее проверим наши смонтированный ФС
```basg
df -h
```

#### 5) Ansible
Ansible позволяет автоматизировать выполнения задач через их описание в файлах, которые называются `плейбуки`. Формат файлов - это `YAML (.yml)`
Исполняются задачи с помощью `ssh`, поэту сначала установим `openssh` на сервер и на машину-клиент.
```bash
apt-get install openssh-server
```

Далее запустим службу на сервере
```bash
systemctl enable --now sshd
```

Теперь перейдем на `CLI`
Здесь необходимо подготовить наш ssh-сервер так, чтобы он понимал входящие подключения по ключу.
Так как задача монтирования и запись в файл /etc/fstab выполняются от имени `root` нам необходимо ключ дать ему
Перейдем в файл `/etc/openssh/sshd_config` (<font color="#e5b9b7">не путать с</font> `ssh_config` )

Нам нужно подправить несколько параметров.
```bash
# /etc/openssh/sshd_config
PermitRootLogin yes # здесь надо раскомментить и написать yes, чтобы разрешмть доутп к руту по паролю
PubkeyAuthentication yes # здесь просто раскомментить

AuthorizedKeysFile      /etc/openssh/authorized_keys/%u /etc/openssh/authorized_keys2/%u .ssh/authorized_keys .ssh/authorized_keys2 # здесь просто раскомментить
```

Теперь вернемся на сервер.
Сначала сгенерируем ключ и поделимся им с клиентким рутом
```bash
ssh-keygen
ssh-copy-id root@cli.au.team
```
Все кайф. Подготовку сделали.
Теперь перейдем к `Ansible`
```bash
apt-get install ansible
```
Сначала необходимо провести инвентаризацию. Для этого перейдем в файл `/etc/ansible/hosts`
Опишем необходимые хосты
```bash
[exam_group] # наша гурппа 
cli.au.team ansible_python_iterpreter /usr/bin/python3 # наш хост 
```
Вообще можно не указывать группу (вроде), а явно указанный интерпретатор нужен, так как у меня ругался `Ansible` без этого, указывал, что по дефолту, как я понял, стоит python2.7

После того как мы прописали наши хосты, сделаем проверку.
```bash
ansible-inventory --list
```
После проверим на всякий работает ли вообще `Ansible`
```bash
anisble exam_group -m ping
```
Если все норм, то идем далее

Теперь создадим файлы:
`playbook_mount_nfs.yml` и `playbook_unmount_nfs.yml`
По синтаксису - без табов, ставить два пробела
```yml
# playbook_mount_nfs.yml
- name: Монтирование NFS на CLI # название плейбука
  hosts: exam_group # на какиех хостах выполнять 
  remote_user: root # от какого пользователя 
  
  tasks: # блок с задачами 
  - name: само монтирование # название задачи 
    mount: # какая команда (задача)
      path: /mnt/nfs # путь куда монтиврем 
      src: l-srv.au.team:/srv/nfsshare # что монтирвем 
      fstype: nfs # тип ФС
      state: mounted # это тип монтирования, данный тип означает что по мимо самого монтирования запись будет добавляться и в /etc/fstab
      opts: defaults # параметр монтирования 
```

```yml
# playbook_unmount_nfs.yml
- name: РАзмонтирование NFS на CLI # название плейбука
  hosts: exam_group # на какиех хостах выполнять 
  remote_user: root # от какого пользователя 
  
  tasks: # блок с задачами 
  - name: удаление временых файлов  # название задачи 
    file: # какая команда (работы с файлами)
      path: /mnt/nfs/* # какой именно файл
      state: absent # удаление файласфе 
      
  - name: размонтирование # название задачи 
    mount: # какая команда (задача)
      path: /mnt/nfs # путь куда монтиврем 
      state: absent # размонтируем и убираем запись из /etc/fstab
     
```

Теперь применяем наши плейбки 
```bash
ansible-playbook playbook_mount_nfs.yml
ansible-playbook playbook_unmount_nfs.yml
``` 
Все - кайф

#### 6) Remote acces
Цель: с компьютера `ADMIN-PC` подключиться по `RDP` к компьютеру `CLI` под пользователем `remote`

Перейдем на `CLI` и установим пакет `xrdp`
```bash
apt-get install -y xrdp
```

Далее создадим пользователя с именем `remote` (по заданию)
```bash
groupadd remoteremote
useradd -m -s /bin/bash -g remoteremote remote
passwd remote
```

Далее необходимо настроить права доступа для нового пользователя. Для этого его необходимо добавить в группу `tsusers`, что у него появился доступ к терминальному сеансу.
```bash
gpasswd -a remote tsusres
# или
# usermod -G tsusers remote

```

Далее запустим службу `xrdp`
```bash
systemctl enable --now xrdp
```

Теперь перейдем на `ADMIN-PC`
Установим `Remmina` и плагин `rdp` для нее
```bash
apt-get install -y remmina remmina-plugins-rdp
```

#### 7) Калькулятор 

```bash
#!/bin/bash
#
if [[ $# > 0 ]]; then
	echo 'без параметров скрипт'
else

read -p 'Какую операцию (+ - / *): ' OP
case $OP in
	'+')
		read -p 'Введите первое слагаемое: ' NUM1
		read -p 'Введите первое слагаемое: ' NUM2
		echo $(($NUM1 + $NUM2))
		;;
	'-')
		read -p 'Введите уменьшаемое: ' NUM1
		read -p 'Введите вычитаемое: ' NUM2
		echo $(($NUM1 - $NUM2))
		;;
	'*')	
		read -p 'Введите первое: ' NUM1
		read -p 'Введите второе: ' NUM2
		echo $(($NUM1 * $NUM2))
		;;
	'/')
		read -p 'Введите делимое: ' NUM1
		read -p 'Введите делитель: ' NUM2
		echo $(($NUM1 / $NUM2))
		;;
	*)
		str="такой операции нет"
		echo $str
		echo "$(date) --> $str" >> /home/calc.log
esac
fi
```
