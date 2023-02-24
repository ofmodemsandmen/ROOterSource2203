#!/bin/sh
. /lib/functions.sh

set=$1

uci set flash.flash.server=$set
uci commit flash