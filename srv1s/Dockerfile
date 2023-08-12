FROM ubuntu:20.04 as srv1s
ARG TZ Europe/Moscow
ENV TZ $TZ
WORKDIR /root
ADD distr /tmp
COPY nethasp.ini logcfg.xml /opt/1cv8/conf/
COPY krb5.conf /etc/krb5.conf
SHELL ["/bin/bash", "-c"]
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y tzdata fonts-liberation fontconfig krb5-user libkrb5-dev apache2 libapache2-mod-php \
        libapache2-mod-auth-kerb iproute2 libc6-i386 kmod && \
        ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
        dpkg-reconfigure -f noninteractive tzdata && \
        fc-cache –fv && \
        a2enmod auth_kerb && \
#        mkdir -p /var/www/1c/ && \
        tar -xvf /tmp/$(ls /tmp/ | grep server64) --directory /tmp/ && \
        /tmp/$(ls /tmp/ | grep setup-full) --mode unattended --disable-components client_full --enable-components server,ws,server_admin,liberica_jre,ru 
#        apt install -y /tmp/haspd_7.90-eter2ubuntu_amd64.deb && \
#        apt install -y /tmp/haspd-modules_7.90-eter2ubuntu_amd64.deb

############################################# 
#RUN apt install -y git
#RUN apt install -y build-essential linux-headers-$(uname -r) linux-image-$(uname -r)
#RUN apt install -y autoconf libtool usbutils
#RUN mkdir /vhci_hcd/
#RUN git clone https://github.com/linuxbuh/vhci_hcd.git /vhci_hcd/
#RUN cd /vhci_hcd/
#RUN mkdir -p linux/"$(uname -r)"/drivers/usb/core
#RUN cp /usr/src/linux-headers-"$(uname -r)"/include/linux/usb/hcd.h linux/"$(uname -r)"/drivers/usb/core/
#WORKDIR /vhci_hcd/
#RUN make KVERSION="$(uname -r)" KSRC=/usr/src/linux-source-"$(uname -r)"

#RUN mkdir /libusb_vhci/
#RUN git clone git://git.code.sf.net/p/usb-vhci/libusb_vhci /libusb_vhci/
#RUN cp /vhci_hcd/usb-vhci.h /usr/include/linux/ && cp /vhci_hcd/usb-vhci.h /usr/local/include/
#WORKDIR /libusb_vhci/
#RUN autoreconf --install && autoconf && ./configure && make

#RUN mkdir /UsbHasp/
#WORKDIR /UsbHasp/
#RUN apt install -y libjansson-dev
#RUN cp /libusb_vhci/src/libusb_vhci.h /usr/local/include && cp /libusb_vhci/src/.libs/* /lib/
#RUN git clone https://github.com/sam88651/UsbHasp.git /UsbHasp/ && cd /UsbHasp/ && make


#COPY 100user.json 1c_server_x64.json haspd_7.90-eter2ubuntu_amd64.deb haspd-modules_7.90-eter2ubuntu_amd64.deb /UsbHasp/

#RUN apt install -y libc6-i386

#RUN apt install -y /UsbHasp/haspd_7.90-eter2ubuntu_amd64.deb
#RUN apt install -y /UsbHasp/haspd-modules_7.90-eter2ubuntu_amd64.deb
#################################
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME [ "/root", "/home/usr1cv8/.1cv8/", "/var/www/1c/", "/etc/apache2/sites-available/" ]
EXPOSE 1540 1541 1560:1591 80 443
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]









