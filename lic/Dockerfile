FROM ubuntu:20.04 as lic1s

WORKDIR /root

RUN apt update && apt install -y cron
COPY libusb-vhci_0.8-2_amd64.deb usb-vhci-hcd-dkms_1.15.1_amd64.deb usbhasp_0.1-2_amd64.deb 100user.json 1c_server_x64.json haspd_7.90-eter2ubuntu_amd64.deb haspd-modules_7.90-eter2ubuntu_amd64.deb healthcheck.sh /root/
RUN  \
        chmod 777 /root/libusb-vhci_0.8-2_amd64.deb &&\
        chmod 777 /root/usb-vhci-hcd-dkms_1.15.1_amd64.deb && \
        chmod 777 /root/usbhasp_0.1-2_amd64.deb
RUN apt update && apt install -y /root/libusb-vhci_0.8-2_amd64.deb
RUN apt install -y /root/usb-vhci-hcd-dkms_1.15.1_amd64.deb
RUN apt install -y /root/usbhasp_0.1-2_amd64.deb
RUN mkdir -p /etc/usbhaspd/keys && \
        cp /root/100user.json /etc/usbhaspd/keys/ && cp /root/1c_server_x64.json /etc/usbhaspd/keys/

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY aksusbd_8.13-1_amd64.deb haspd_7.90-eter2ubuntu_amd64.deb haspd-modules_7.90-eter2ubuntu_amd64.deb healthcheck.sh /root/
RUN apt install -y libc6-i386
RUN apt install -y /root/haspd_7.90-eter2ubuntu_amd64.deb
RUN apt install -y /root/haspd-modules_7.90-eter2ubuntu_amd64.deb
#RUN apt install -y /root/aksusbd_8.13-1_amd64.deb

COPY hasplm.conf /etc/haspd/hasplm.conf

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
