#!/bin/bash

set -x

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo yum -y update
sudo yum -y upgrade
sudo yum -y install python38
sudo pip-3.8 install redis
sudo useradd www -s /sbin/nologin
mkdir -p /var/lib/www/cgi-bin
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

cat << EOF > /var/lib/www/cgi-bin/hello.py
#!/usr/bin/env python3

import redis

r = redis.Redis(
                host='${database_host}',
                port=6379)
r.set('count', 0)
count = r.incr(1)

print("Content-type: text/html")
print("")
print("<html><body>")
print("<p>Hello World!<br />counter: " + str(count) + "<br />env: ${environment}</p>")
print("Id: $INSTANCE_ID")
print("</body></html>")
EOF

cat << EOF > /var/lib/www/cgi-bin/ping.py
#!/usr/bin/env python3

print("Content-type: text/html")
print("")
print("<html><body>")
print("<p>ok</p>")
print("</body></html>")
EOF

chmod 755 /var/lib/www/cgi-bin/hello.py
chmod 755 /var/lib/www/cgi-bin/ping.py
cd /var/lib/www
sudo -u www python3 -m http.server 8000 --cgi
