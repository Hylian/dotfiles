#!/bin/sh

headphones_id=$(pw-cli info alsa_output.usb-Topping_D50-00.HiFi__Headphones__sink | head -n 1 | awk '{print $2}')
speakers_id=$(pw-cli info alsa_output.usb-Focusrite_Scarlett_Solo_USB_Y7WBXER4518154-00.HiFi__Line1__sink | head -n 1 | awk '{print $2}')

if wpctl status | /usr/bin/rg -A 2 Settings | /usr/bin/rg -q Scarlett; then
  wpctl set-default "$headphones_id"
else
  wpctl set-default "$speakers_id"
fi
