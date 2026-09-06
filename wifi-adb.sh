#!/bin/bash
adb kill-server
sleep 1
adb tcpip 5555
sleep 1
adb connect 192.x.x.x:5555
