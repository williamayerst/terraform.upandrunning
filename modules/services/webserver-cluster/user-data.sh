#!/bin/bash
yum install -y httpd
cat > /var/www/html/index.html <<EOF
<html>
<font face="Calibri"><h1>${server_text}</h1>
<ul>
<li>DB address: ${db_address}</li>
<li>DB port: ${db_port}</li>
</ul>
</font>
</html>
EOF
chkconfig httpd on
service httpd start
yum update -y