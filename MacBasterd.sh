#!/bin/bash
# Made by Mick Beer to detect new devices on the network and scan for CVEs

# Set the time interval between scans (in seconds)
interval=3

# Set the output directory for exploit downloads
output_dir="/tmp/exploits"

# Create the output directory if it doesn't exist
if [ ! -d "$output_dir" ]; then
  mkdir "$output_dir"
fi

# Loop infinitely, scanning the network at the specified interval
while true; do
  # Get the list of IP addresses on the network using arp-scan
  echo "Scanning for new devices on the network..."
  new_ips=$(sudo arp-scan --localnet --numeric --quiet --ignoredups | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' | awk '{print $1}')
  echo "Scan for new devices on the network completed."

  # Check if there are any new devices on the network
  if [ -n "$new_ips" ]; then
    echo "New devices found on the network: $new_ips"
    notify-send -u normal "New devices found on the network" "$new_ips"

    # Loop through the new IP addresses and scan them for CVEs
    for ip_address in $new_ips; do
      echo "Scanning $ip_address for CVEs..."
      nmap_output=$(nmap -Pn --script vuln --script-args vulns.showall -oX - $ip_address | xmllint --xpath "//script_output" - 2>/dev/null | sed 's/<\/*script_output>//g' | tr -d '\n' | sed 's/  \+/ /g')

      # Check if any CVEs were found
      if [ -n "$nmap_output" ]; then
        echo "CVEs found on $ip_address: $nmap_output"

        # Loop through the CVEs and download corresponding exploits from exploit-db.com
        while read -r cve; do
          echo "Downloading exploits for $cve from exploit-db.com..."
          search_string="https://www.exploit-db.com/search\?action=search\&q=$cve"
          search_result=$(curl -s "$search_string")
          exploit_url=$(echo "$search_result" | grep -o 'https://www.exploit-db.com/exploits/[0-9]\+' | head -1)
          if [ -n "$exploit_url" ]; then
            exploit_id=$(echo "$exploit_url" | grep -o '[0-9]\+')
            wget -q -P "$output_dir" "https://www.exploit-db.com/download/$exploit_id"
            echo "Exploits downloaded for $cve"
          else
            echo "No exploits found for $cve"
          fi
        done <<< "$(echo "$nmap_output" | grep -Eo 'CVE-[0-9]+-[0-9]+' | sort -u)"
      else
        echo "No CVEs found on $ip_address"
      fi
    done
  else
    echo "No new devices found on the network."
  fi

  # Wait for the specified interval
  echo "Waiting for $interval seconds..."
  sleep "$interval"
done
