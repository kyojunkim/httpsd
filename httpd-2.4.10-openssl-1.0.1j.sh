#!/bin/bash

INSTALL_PATH=$1
HTTPS_DOMAIN=$2
HTTP_PORT=$3
HTTPS_PORT=$4

mkdir -p $INSTALL_PATH

wget -nc http://archive.apache.org/dist/httpd/httpd-2.4.10.tar.gz
wget -nc http://apache.mirror.cdnetworks.com/apr/apr-1.5.1.tar.gz
wget -nc http://apache.mirror.cdnetworks.com/apr/apr-util-1.5.4.tar.gz
wget -nc http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-8.36.tar.gz
wget -nc http://zlib.net/zlib-1.2.8.tar.gz
wget -nc http://www.openssl.org/source/openssl-1.0.1j.tar.gz

tar zxvf httpd-2.4.10.tar.gz
tar zxvf zlib-1.2.8.tar.gz
tar zxvf pcre-8.36.tar.gz
tar zxvf apr-1.5.1.tar.gz
tar zxvf apr-util-1.5.4.tar.gz
tar zxvf openssl-1.0.1j.tar.gz

cd zlib-1.2.8
./configure --prefix=$INSTALL_PATH/zlib-1.2.8;make;make install;
cd ..

cd pcre-8.36
make clean
./configure --prefix=$INSTALL_PATH/pcre-8.36;make;make install;
cd ..

cd openssl-1.0.1j
make clean
./config --prefix=$INSTALL_PATH/openssl-1.0.1j --openssldir=$INSTALL_PATH/openssl-1.0.1j shared;make;make install;
cd ..

cd apr-1.5.1
make clean
cp -r libtool libtoolT 2> /dev/null
./configure --prefix=$INSTALL_PATH/apr-1.5.1;make;make install;
cd ..

cd apr-util-1.5.4
make clean
./configure --prefix=$INSTALL_PATH/apr-util-1.5.4 --with-apr=$INSTALL_PATH/apr-1.5.1;make;make install;
cd ..

export LDFLAGS=-L$INSTALL_PATH/openssl-1.0.1j/lib;
cd httpd-2.4.10
make clean
./configure --prefix=$INSTALL_PATH/httpd-2.4.10  --with-apr=../apr-1.5.1 --with-apr-util=../apr-util-1.5.4 --with-pcre=$INSTALL_PATH/pcre-8.36/bin/pcre-config --with-ssl=$INSTALL_PATH/openssl-1.0.1j --enable-ssl --with-z=$INSTALL_PATH/zlib-1.2.8 --enable-so --enable-mpms-shared=all --enable-mods-shared=all;make;make install;
cd ..

cp ./httpd.conf $INSTALL_PATH/httpd-2.4.10/conf/httpd.conf
cp ./httpd-ssl.conf $INSTALL_PATH/httpd-2.4.10/conf/extra/
cp ./server.key $INSTALL_PATH/httpd-2.4.10/conf/
cp ./server.crt $INSTALL_PATH/httpd-2.4.10/conf/

INSTALL_PATH_STRING="${INSTALL_PATH//\//\\/}"
sed -i 's/Listen 80/Listen '"$HTTP_PORT"'/g' $INSTALL_PATH/httpd-2.4.10/conf/httpd.conf
sed -i 's/Listen 443/Listen '"$HTTPS_PORT"'/g' $INSTALL_PATH/httpd-2.4.10/conf/extra/httpd-ssl.conf
sed -i 's/_default_/'"$HTTPS_DOMAIN"'/g' $INSTALL_PATH/httpd-2.4.10/conf/httpd.conf
sed -i 's/_default_/'"$HTTPS_DOMAIN"'/g' $INSTALL_PATH/httpd-2.4.10/conf/extra/httpd-ssl.conf
sed -i 's/_port_/'"$HTTPS_PORT"'/g' $INSTALL_PATH/httpd-2.4.10/conf/extra/httpd-ssl.conf
sed -i 's/_install_path_/'"$INSTALL_PATH_STRING"'/g' $INSTALL_PATH/httpd-2.4.10/conf/extra/httpd-ssl.conf
sed -i 's/_install_path_/'"$INSTALL_PATH_STRING"'/g' $INSTALL_PATH/httpd-2.4.10/conf/httpd.conf


$INSTALL_PATH/httpd-2.4.10/bin/apachectl restart
$INSTALL_PATH/httpd-2.4.10/bin/ab -n 1000 https://$HTTPS_DOMAIN:$HTTPS_PORT/index.html
