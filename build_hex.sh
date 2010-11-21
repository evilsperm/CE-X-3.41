#!/usr/bin/env bash
#
# Copyright (C) Youness Alaoui (KaKaRoTo)
#
# This software is distributed under the terms of the GNU General Public
# License ("GPL") version 3, as published by the Free Software Foundation.
#

all_targets="teensy1 teensypp1 teensy2 teensypp2 \
              at90usbkey minimus1 minimus32 maximus \
              blackcat xplain olimex usbtinymkii \
              bentio openkubus atvrusbrf01 udip8 udip16 \
	      avrkey ps2chiper jmdbu2"

function is_mcu_supported() {
  avr-gcc --target-help | awk '/^Known MCU names:$/,/^$/' | grep -q $1
}

i=1
for target in ${all_targets}; do
  let ${target}=$i
  let i++
done

if command -v gmake &>/dev/null; then
	MAKE=gmake
else
	MAKE=make
fi

mcu[$teensy1]=at90usb162
board[$teensy1]=TEENSY
mhz_clock[$teensy1]=16
name[$teensy1]="Teensy 1.0"

mcu[$teensypp1]=at90usb646
board[$teensypp1]=TEENSY
mhz_clock[$teensypp1]=16
name[$teensypp1]="Teensy++ 1.0"

mcu[$teensy2]=atmega32u4
board[$teensy2]=TEENSY
mhz_clock[$teensy2]=16
name[$teensy2]="Teensy 2.0"

mcu[$teensypp2]=at90usb1286
board[$teensypp2]=TEENSY
mhz_clock[$teensypp2]=16
name[$teensypp2]="Teensy++ 2.0"

mcu[$at90usbkey]=at90usb1287
board[$at90usbkey]=USBKEY
mhz_clock[$at90usbkey]=8
name[$at90usbkey]="AT90USBKEY"

mcu[$minimus1]=at90usb162
board[$minimus1]=MINIMUS
mhz_clock[$minimus1]=16
name[$minimus1]="Minimus v1"

mcu[$minimus32]=atmega32u2
board[$minimus32]=MINIMUS
mhz_clock[$minimus32]=16
name[$minimus32]="Minimus 32"

mcu[$maximus]=at90usb162
board[$maximus]=MAXIMUS
mhz_clock[$maximus]=16
name[$maximus]="Maximus"

mcu[$blackcat]=at90usb162
board[$blackcat]=BLACKCAT
mhz_clock[$blackcat]=16
name[$blackcat]="Blackcat"

mcu[$xplain]=at90usb1287
board[$xplain]=XPLAIN
mhz_clock[$xplain]=8
name[$xplain]="XPLAIN"

mcu[$olimex]=at90usb162
board[$olimex]=OLIMEX
mhz_clock[$olimex]=8
name[$olimex]="Olimex"

mcu[$usbtinymkii]=at90usb162
board[$usbtinymkii]=USBTINYMKII
mhz_clock[$usbtinymkii]=16
name[$usbtinymkii]="USBTINYMKII"

mcu[$bentio]=at90usb162
board[$bentio]=BENTIO
mhz_clock[$bentio]=16
name[$bentio]="Bentio"

mcu[$openkubus]=atmega16u4
board[$openkubus]=USBKEY
mhz_clock[$openkubus]=8
name[$openkubus]="OpenKubus"

mcu[$atvrusbrf01]=at90usb162
board[$atvrusbrf01]=ATAVRUSBRF01
mhz_clock[$atvrusbrf01]=16
name[$atvrusbrf01]="ATAVRUSBRF01"

mcu[$udip8]=at90usb162
board[$udip8]=UDIP
mhz_clock[$udip8]=8
name[$udip8]="UDIP8"

mcu[$udip16]=at90usb162
board[$udip16]=UDIP
mhz_clock[$udip16]=16
name[$udip16]="UDIP16"

mcu[$avrkey]=atmega32u2
board[$avrkey]=AVRKEY
mhz_clock[$avrkey]=16
name[$avrkey]="AVRKEY"

mcu[$ps2chiper]=at90usb162
board[$ps2chiper]=PS2CHIPER
mhz_clock[$ps2chiper]=8
name[$ps2chiper]="PS2CHIPER"

mcu[$jmdbu2]=atmega32u4
board[$jmdbu2]=JMDBU2
mhz_clock[$jmdbu2]=8
name[$jmdbu2]="JMDBU2"

while [ "x$1" != "x" ]; do
  targets="$targets ${1}"
  shift
done
if [ "x$targets" == "x" ]; then
  for i in ${all_targets}; do
    targets="$targets ${i}"
  done
fi

echo "Building for targets : $targets"

rm -rf psgroove_hex/
mkdir psgroove_hex
$MAKE clean_list > /dev/null

for target in ${targets}; do
  if ! is_mcu_supported "${mcu[${!target}]}"; then
    echo "$target compilation skipped. Your avr-gcc does not support ${mcu[${!target}]}." >&2
    continue
  fi
  for firmware in 3.41 ; do
    firmware=${firmware/./_}
    low_board=`echo ${board[${!target}]} | awk '{print tolower($0)}'`
    filename="psgroove_${low_board}_${mcu[${!target}]}_${mhz_clock[${!target}]}mhz_firmware_${firmware}"
    echo "Compiling $filename for ${name[${!target}]}"
    $MAKE TARGET=$filename MCU=${mcu[${!target}]} BOARD=${board[${!target}]} F_CPU=${mhz_clock[${!target}]}000000 FIRMWARE_VERSION=${firmware} > /dev/null || exit 1
    mkdir -p "psgroove_hex/${name[${!target}]}"
    mv *.hex "psgroove_hex/${name[${!target}]}/"
    $MAKE clean_list TARGET=$filename > /dev/null
  done
done

