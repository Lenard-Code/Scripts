#!/bin/bash

# Check if an IP or network was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <target_ip_or_network>"
    exit 1
fi

# Define the target network or IP range from the command-line argument
TARGET="$1"
OUTPUT_DIR="./nmap_results"
mkdir -p $OUTPUT_DIR

# Function to check if the host is up
check_host_up() {
    local host=$1
    nmap -sn $host -oG - | grep -q "Status: Up"
}

# Perform the initial scan to confirm hosts are up
echo "Performing initial host discovery..."
nmap -sn $TARGET -oG - | awk '/Up$/{print $2}' > $OUTPUT_DIR/up_hosts.txt

# Loop through each discovered host and perform detailed scans
while IFS= read -r host; do
    echo "Scanning host: $host"

    # Perform TCP scan
    echo "Performing TCP scan on $host..."
    nmap -sT -A -O -v $host -oN $OUTPUT_DIR/tcp_scan_$host.txt

    # Perform UDP scan
    echo "Performing UDP scan on $host..."
    nmap -sU -A -O -v $host -oN $OUTPUT_DIR/udp_scan_$host.txt

    # Perform ICMP and non-ICMP discovery
    echo "Performing ICMP and non-ICMP discovery on $host..."
    nmap -PE -PS -PA -PP -v $host -oN $OUTPUT_DIR/icmp_scan_$host.txt

    # Combine results into a single file for each host
    echo "Combining results for host: $host"
    cat $OUTPUT_DIR/tcp_scan_$host.txt $OUTPUT_DIR/udp_scan_$host.txt $OUTPUT_DIR/icmp_scan_$host.txt > $OUTPUT_DIR/combined_scan_$host.txt

done < $OUTPUT_DIR/up_hosts.txt

# Create a final document with all the results
FINAL_OUTPUT="$OUTPUT_DIR/final_results.txt"
echo "Creating final document with all results..."
echo "NMAP Network Scan Results" > $FINAL_OUTPUT
echo "=========================" >> $FINAL_OUTPUT

while IFS= read -r host; do
    echo "Results for host: $host" >> $FINAL_OUTPUT
    cat $OUTPUT_DIR/combined_scan_$host.txt >> $FINAL_OUTPUT
    echo -e "\n\n" >> $FINAL_OUTPUT
done < $OUTPUT_DIR/up_hosts.txt

echo "Network scan complete. All results are saved in $FINAL_OUTPUT."
