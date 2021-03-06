#!/bin/bash

echo "--------------------------------------------- CPU STATUS ------------------------------------------------"
echo ""

echo "----------------- PASSIVE INFORMATION --------------------------"
echo ""

# info about CPU archiecture
cpu_architecture=$(lscpu | head -n 1)
echo $cpu_architecture

cpu_bit=$(lscpu | grep "CPU op-mode(s)" | grep -o "[0-9]*-bit" | tail -n 1)
echo "Register Bit size(CPU): $cpu_bit"

# CPU model
cpu_model=$(lscpu | grep "Model name:")
echo $cpu_model

# Works for Intel CPU only
org=$(echo $cpu_model | grep -o "Intel")
if [ $org = "Intel" ]
then
base_clock_cycle=$(echo $cpu_model | grep -o "[0-9.]*GHz")
echo "Base clock cycle: $base_clock_cycle"
fi

# Total number of cores(CPU)
num_cores_per_socket=$(lscpu | grep "Core(s) per socket:" | grep -o "[0-9]*")
num_socket=$(lscpu | grep "Socket(s):" | grep -o "[0-9]*")
num_cores=$(($num_cores_per_socket * $num_socket))
echo "Number of CPU cores: $num_cores"

# Total number of Physical threads
threads_per_core=$(lscpu | grep "Thread(s) per core:" | grep -o "[0-9]")
total_threads=$(( $threads_per_core * $num_cores ))
echo "Number of Physical Threads(CPU): $total_threads"

echo ""
echo ""
echo "-------------------- ACTIVE INFORMATION ---------------------------"
echo ""

# Display time duration since last boot
curr_epoch_duration=$(date +%s)
temp=$(cat /proc/stat | grep "btime")
boot_time_epoch_duration=$(echo $temp | awk '{print $2}')
active_duration_seconds=$(( $curr_epoch_duration - $boot_time_epoch_duration ))
echo "Time duration since last boot: $((${active_duration_seconds} / 3600)) hours: \
$((${active_duration_seconds} % 3600 / 60)) minutes : $((${active_duration_seconds} % 3600 % 60)) seconds"
# Display number of active processes
# using "ps" to display process list only display the processes which are initiated as a part/on the WSL platform. Host windows processes are never recorded.
# Would have appreciated if both windows and WSL stats were combined and provided. Windows support is not available now!
# But the command will work fine in a real linux kernels

num_active_processes=$(ps -ef | wc -l)
echo "Number of active processes: $(($num_active_processes - 3))"
# Here 3 is subtracted to minus the count of ps, initial column name and one more row due to pipe or wc process.
# These 3 processes are used in the first place to find the count of active processes.

# Display list of active processes
# only display the active processes which are initated in WSL platform and not the host Windows platform.
echo ""
echo "-------------------- PROCESS LIST -------------------"

tmp=$(($num_active_processes - 3))
for ((i = 1 ; i <= ($tmp - 2) ; i++));
do
    pid=$(ps -e | head -n $(($i + 1)) | tail -n 1 | awk '{print $1}')
    pname=$(ps -e | head -n $(($i + 1)) | tail -n 1 | awk '{print $4}')
    echo "Process id (PID): $pid           process name: $pname"
done

echo "-----------------------------------------------------"

# TODO: Understand /proc/loadaverage and /proc/uptime
# TODO: system files for Cpu stats such  as temp,fan speed etc are not available for WSL.
# Idea: Can use the windows system files to gather such data. Have to do a little research and figure out , if it is possible
# problem: Various sensor informations are not supported by WSL (virtualized kernel). Windows might be doing that,so maybe to get that
#      --> information in WSL,have to parse such system files in windows filesystem to scrap the data.
echo ""
echo "-----------------------------------------------------------------------------------------------------------"