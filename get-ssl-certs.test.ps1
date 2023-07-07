param (
    [Parameter(Mandatory=$true, HelpMessage="Full path and name of CSV file containing sites to check")]
    [string]$ServersCSV
)

$date = Get-Date
$DateStr = $Date.ToString("yyyyMMdd")
$csvfile = ".\$DateStr.certdata.csv"
$outfile = ".\output.html"

# Check if CSV file exists, then delete
if (Test-Path $csvfile) {
    Remove-Item $csvfile
}

# Check if HTML file exists, then delete
if (Test-Path $outfile) {
    Remove-Item $outfile
}

$HtmlHead = '<style>
    body {
        background-color: white;
        font-family: "Calibri";
    }

    table {
        border-width: 1px;
        border-style: solid;
        border-color: black;
        border-collapse: collapse;
        width: 100%;
    }

    th {
        border-width: 1px;
        padding: 5px;
        border-style: solid;
        border-color: black;
        background-color: #98C6F3;
    }

    td {
        border-width: 1px;
        padding: 5px;
        border-style: solid;
        border-color: black;
        background-color: White;
    }

    tr {
        text-align: left;
    }
</style>'

$arrServers = Import-Csv $ServersCSV

foreach ($objServer in $arrServers) {
    $issuerLong = ""
    $certeffective = ""
    $certexpire = ""
    $servershort = ""
    $expiredays = ""

    Write-Host "Server: [$($objServer.ServerName)] Function: [$($objServer.function)]"

    [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

    $servername = $objServer.ServerName
    $url = "https://$servername/"

    $req = [Net.HttpWebRequest]::Create($url)
    $req.timeout = 5000 # 5 seconds

    try {
        $req.GetResponse() | Out-Null

        $certeffective = $req.ServicePoint.Certificate.GetEffectiveDateString()
        $certexpire = $req.ServicePoint.Certificate.GetExpirationDateString()
        $issuerLong = $req.ServicePoint.Certificate.Issuer
        $thumb = $req.ServicePoint.Certificate.GetCertHashString()

        switch -Regex ($issuerLong) {
            'comodo'   { $strIssuer = "Comodo" }
            'verisign' { $strIssuer = "VeriSign" }
            'UnitedHealth Group' { $strIssuer = "UHG" }
            'OptumInternalIssuingCA2' { $strIssuer = "OptumInternalCA2" }
            $ServerName { $strIssuer = "Self Signed" }
            default { $strIssuer = $issuerLong }
        }

        $servershort = $servername.Split("/")[0]
        $now = Get-Date
        $expiredays = (New-TimeSpan -Start $now -End $certexpire).Days

        $data = [PSCustomObject]@{
            'ServerName' = $servershort
            'Function' = $objServer.function
            'Issuer' = $strIssuer
            'Effective' = $certeffective
            'Expire' = $certexpire
            'Thumbprint' = $thumb
            'DaysToExpire' = $expiredays
        }

        $data | Export-CSV $csvfile -Append -NoTypeInformation -Force

        Write-Host "Expire Date: $certexpire"
    }
    catch {
        Write-Host "Failed to connect to the server: $servername"
    }
}

Import-Csv $csvfile | Sort-Object DaysToExpire, Servername | ConvertTo-Html -Head $HtmlHead | Out-File $outfile
