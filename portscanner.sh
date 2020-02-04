#!/bin/bash
#Usage: ./portscanner.sh example.com

host $1 | grep "${1} has address " | cut -d ' ' -f 4 > ips-target.txt
mkdir Scans/$1
declare -a arrPorts
while IFS= read -r line
do
    #Masscan scanning
    echo "SCANNING $line IP"
    bin/masscan $line -p0-65535 --max-rate 10000 -sS -Pn -n -oL temp_${line}.txt
    cat temp_${line}.txt | grep "open" | cut -d ' ' -f 3 | sort -n > nmap_${line}.txt

    #Appending ports to an array
    arrPorts=()
    for port in $(cat nmap_${line}.txt); do
        arrPorts=("${arrPorts[@]}" $port)
    done
    nPorts="$(IFS=,; printf '%s' "${arrPorts[*]}")"

    #Nmap scanning
    nmap -sV --data-length=50 -p $nPorts $line -oG Scans/$1/ports_${line}.txt

    rm temp_${line}.txt
    rm nmap_${line}.txt
    echo ""
done < ips-target.txt
rm ips-target.txt
