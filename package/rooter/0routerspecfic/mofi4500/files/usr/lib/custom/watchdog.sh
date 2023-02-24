#!/bin/sh

wd_gpio="7"
wd1_gpio="13"

echo $wd_gpio > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$wd_gpio/direction
echo 1 >/sys/class/gpio/gpio$wd_gpio/value


echo $wd1_gpio > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$wd1_gpio/direction
echo 1 >/sys/class/gpio/gpio$wd1_gpio/value