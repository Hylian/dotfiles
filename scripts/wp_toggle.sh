#!/bin/sh

headphones_name="alsa_output.usb-Topping_D50-00.HiFi__Headphones__sink"
speakers_name="alsa_output.usb-Burr-Brown_from_TI_USB_Audio_DAC-00.analog-stereo"

headphones_id=$(pw-cli info $headphones_name | head -n 1 | awk '{print $2}')
speakers_id=$(pw-cli info $speakers_name | head -n 1 | awk '{print $2}')

if wpctl status | /usr/bin/rg -A 2 Settings | /usr/bin/rg -q $speakers_name; then
  wpctl set-default "$headphones_id"
else
  wpctl set-default "$speakers_id"
fi
