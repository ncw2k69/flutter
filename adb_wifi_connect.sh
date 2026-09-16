#!/usr/bin/env bash

# Color formatting
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "      ADB Multi-Device Wi-Fi Setup        "
echo "=========================================="

# 1. Kill and restart ADB server
echo "[+] Resetting ADB server..."
adb kill-server
adb start-server > /dev/null 2>&1

# 2. Get list of USB connected devices (excluding already connected IP targets)
echo "[+] Scanning for USB connected devices..."
devices=$(adb devices | grep -v "List" | grep -v ":" | grep "device$" | awk '{print $1}')

if [ -z "$devices" ]; then
    echo -e "${RED}[!] No USB devices found! Connect devices via USB and enable USB Debugging.${NC}"
    exit 1
fi

port=5555
declare -a connected_devices=()
declare -a failed_devices=()

# 3. Process each device
for device_id in $devices; do
    echo "------------------------------------------"
    echo "[+] Processing device: $device_id (Assigned Port: $port)"

    # Extract Wi-Fi IP address from device wlan0 interface
    ip_addr=$(adb -s "$device_id" shell "ip route" 2>/dev/null | awk '/wlan0/ {print $NF}' | head -n 1)

    # Fallback IP extraction method if ip route fails
    if [ -z "$ip_addr" ]; then
        ip_addr=$(adb -s "$device_id" shell "ip -o -4 addr show wlan0" 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    fi

    if [ -z "$ip_addr" ]; then
        echo -e "    ${RED}[-] Could not extract IP address. Ensure Wi-Fi is connected.${NC}"
        failed_devices+=("$device_id (Reason: No IP found)")
        ((port++))
        continue
    fi

    echo "    IP Address: $ip_addr"

    # Set TCP/IP port
    echo "    Switching device to TCP/IP mode on port $port..."
    adb -s "$device_id" tcpip "$port" > /dev/null 2>&1
    sleep 2

    # Connect over Wi-Fi
    echo "    Connecting to $ip_addr:$port..."
    connect_output=$(adb connect "$ip_addr:$port" 2>&1)

    if echo "$connect_output" | grep -q "connected to"; then
        echo -e "    ${GREEN}[✓] Successfully connected to $ip_addr:$port${NC}"
        connected_devices+=("$device_id -> $ip_addr:$port")
    else
        echo -e "    ${RED}[✗] Failed to connect to $ip_addr:$port${NC}"
        failed_devices+=("$device_id -> $ip_addr:$port ($connect_output)")
    fi

    ((port++))
done

# 4. Connection Statistics Summary
echo "=========================================="
echo "          CONNECTION SUMMARY              "
echo "=========================================="
total_usb=$(echo "$devices" | wc -w | tr -d ' ')
echo -e "Total USB Devices Detected: $total_usb"
echo -e "Successfully Connected:     ${GREEN}${#connected_devices[@]}${NC}"
echo -e "Failed Connections:         ${RED}${#failed_devices[@]}${NC}"
echo "------------------------------------------"

if [ ${#connected_devices[@]} -gt 0 ]; then
    echo -e "${GREEN}Connected Targets:${NC}"
    for dev in "${connected_devices[@]}"; do
        echo "  - $dev"
    done
fi

if [ ${#failed_devices[@]} -gt 0 ]; then
    echo -e "${RED}Failed Targets:${NC}"
    for dev in "${failed_devices[@]}"; do
        echo "  - $dev"
    done
fi

echo "=========================================="