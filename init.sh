sudo dpkg --add-architecture i386
sudo apt update
sudo apt install lib32z1 libncurses5:i386 libbz2-1.0:i386 lib32gcc-s1 lib32stdc++6 libtinfo5:i386 libcurl3-gnutls:i386 -y
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar zxf steamcmd_linux.tar.gz
rm -rf steamcmd_linux.tar.gz
chmod +x tf.sh
chmod +x steamcmd.sh update.sh
./update.sh +runscript tf2_ds.txt
