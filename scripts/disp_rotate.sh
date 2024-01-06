#!/bin/bash
sudo chmod a+rw /dev/usb/hiddev0
sudo chmod a+rw /dev/usb/hiddev1
python ~/acdcontrol/acdcontrol.py /dev/usb/hiddev0 65535
python ~/acdcontrol/acdcontrol.py /dev/usb/hiddev1 65535
