# Connect ADB via Wi-Fi
1. Connect the device via USB and make sure debugging is working

This makes the device to start listening for connections on port 5555;
```shell
adb tcpip 5555
```
2. Look up the device IP address with 
```shell
adb shell netcfg
``` 
```shell
adb shell ifconfig
```
With 6.0 and higher or 
```shell
adb shell ip -f inet addr show
``` 
Check Wi-Fi IP address in settings
```
Settings > Connections > Wi-Fi > Router > IP Settings
```
3. You can disconnect the USB now
```shell
adb connect <DEVICE_IP_ADDRESS>:5555
``` 
