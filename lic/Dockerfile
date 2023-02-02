FROM ubuntu:20.04 as lic1s

WORKDIR /root
COPY libusb-vhci_0.8-2_amd64.deb usb-vhci-hcd-dkms_1.15.1_amd64.deb usbhasp_0.1-2_amd64.deb 100user.json 1c_server_x64.json haspd_7.90-eter2ubuntu_amd64.deb haspd-modules_7.90-eter2ubuntu_amd64.deb healthcheck.sh entrypoint.sh hasplm.conf /root/
RUN  apt update && \
        apt install -y /root/libusb-vhci_0.8-2_amd64.deb &&\
        apt install -y /root/usb-vhci-hcd-dkms_1.15.1_amd64.deb && \
        apt install -y /root/usbhasp_0.1-2_amd64.deb && \
        mkdir -p /etc/usbhaspd/keys && \
        mv /root/100user.json /root/1c_server_x64.json /etc/usbhaspd/keys/ && \
        apt install -y libc6-i386 && \
        apt install -y /root/haspd_7.90-eter2ubuntu_amd64.deb && \
        apt install -y /root/haspd-modules_7.90-eter2ubuntu_amd64.deb && \
        mv /root/entrypoint.sh /usr/local/bin/ && chmod +x /usr/local/bin/entrypoint.sh && \
        rm -rf /etc/haspd/hasplm.conf && mv /root/hasplm.conf /etc/haspd/ && \
        rm /root/libusb-vhci_0.8-2_amd64.deb /root/usb-vhci-hcd-dkms_1.15.1_amd64.deb /root/usbhasp_0.1-2_amd64.deb /root/haspd_7.90-eter2ubuntu_amd64.deb /root/haspd-modules_7.90-eter2ubuntu_amd64.deb
        
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]












