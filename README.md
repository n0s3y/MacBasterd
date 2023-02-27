# MacBasterd

## IP2Exploit but scans automatically within network and detects, downloads and executes these exploits. Your network is exploited and tested and provided with results

### Example Output when no hosts that are vulnerable are detected:
```New devices found on the network: Interface:
192.168.2.x
192.168.2.x
192.168.2.x
192.168.2.x
Scanning Interface: for CVEs...
No CVEs found on Interface:
Scanning 192.168.2.x for CVEs...
No CVEs found on 192.168.2.x
Scanning 192.168.2.x for CVEs...
No CVEs found on 192.168.2.x
Scanning 192.168.2.x for CVEs...
No CVEs found on 192.168.2.x
Scanning 192.168.2.x for CVEs...
No CVEs found on 192.168.2.x
Waiting for 3 seconds...
Scanning for new devices on the network...
Scan for new devices on the network completed.
```
#### To run this script as a cronjob in the background, you can add the following line to your crontab file (crontab -e):
```

* * * * * /path/to/network_monitor.sh >/dev/null 2>&1 &
```
