#!/bin/sh
. /lib/functions.sh

set=$1

uci set flash.flash.random=$set
uci commit flash