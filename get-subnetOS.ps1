# Al Holguin
# July 25 2023
#
# Crawl through subnet, report on OS of found devices
#
# Define the subnet range (e.g., 192.168.1.0/24)
$subnet = "172.16.1."

# Function to check if a device is online using Test-Connection
function Test-Online {
    param([string]$computerName)
    Test-Connection -ComputerName $computerName -Count 1 -Quiet
}

# Function to get the operating system of a device using WMI
function Get-OSInfo {
    param([string]$computerName)
    $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName -ErrorAction SilentlyContinue
    if ($os) {
        return $os.Caption
    } else {
        return "Offline or WMI query failed"
    }
}

# Loop through the subnet and check each device
for ($i = 1; $i -le 254; $i++) {
    $ipAddress = $subnet + $i
    if (Test-Online -computerName $ipAddress) {
        $osInfo = Get-OSInfo -computerName $ipAddress
        $devicename = Resolve-DnsName -Type PTR -Name $ipAddress -ErrorAction SilentlyContinue | Select-Object -ExpandProperty NameHost -ErrorAction SilentlyContinue
        Write-Host "$ipAddress,$devicename,$osInfo"
    }
}
