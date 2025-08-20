#!/bin/bash
# server-stats.sh
# Script to analyze basic server performance stats on Linux


echo "==============================="
echo "     SERVER PERFORMANCE STATS   "
echo "==============================="
# OS Version
echo -e "\n👉 OS Version:"
cat /etc/os-release 2>/dev/null | grep -E 'PRETTY_NAME' | cut -d= -f2 | tr -d '"' || uname -a

# Uptime & Load
echo -e "\n👉 Uptime:"
uptime -p 2>/dev/null || true
echo "Load average (1/5/15 min): $(uptime | awk -F'load average: ' '{print $2}')"

# Logged in users
echo -e "\n👉 Logged in users:"
who || true

# CPU Usage
echo -e "\n👉 Total CPU Usage:"
if command -v mpstat >/dev/null 2>&1; then
  mpstat 1 1 | awk '/Average/ && $2 ~ /all/ {printf "User: %.1f%% | System: %.1f%% | Idle: %.1f%% | IOWait: %.1f%%\n", $3, $5, $12, $6}'
else
  top -b -n1 | awk -F'[, ]+' '/^%?Cpu/ {printf "User: %s | System: %s | Idle: %s | IOWait: %s\n", $2"%", $4"%", $8"%", $6"%"}'
fi


# Memory Usage
echo -e "\n👉 Total Memory Usage:"
free -h | awk 'NR==2{printf "Used: %s | Free: %s | (%.2f%% Used)\n", $3, $4, ($3/$2)*100}'

echo -e "\n👉 Total Disk Usage:"
df -h --total | awk '/total/ {used=$3; free=$4; sub("%","",$5); printf "Used: %s | Free: %s | (%s Used)\n", used, free, $5}'

# Top Processes
echo -e "\n👉 Top 5 Processes by CPU Usage:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
echo -e "\n👉 Top 5 Processes by Memory Usage:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6

# Failed logins
if command -v lastb >/dev/null 2>&1; then
  echo -e "\n👉 Failed Login Attempts (last 5):"
  (sudo -n lastb || lastb) 2>/dev/null | head -n 5
else
  echo -e "\n👉 Failed Login Attempts: 'lastb' not available."
fi


echo -e "\n👉 OS Kernel & Architecture:"
uname -srmo

echo -e "\n👉 Current Time:"
date

echo -e "\n==============================="
echo "        END OF REPORT"
echo "==============================="
