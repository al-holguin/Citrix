#serverFQDN, ServerFunction
#wp0000501232, cloudconnector
#html output
#Al Holguin 2023
 
param (
    # CSV File containing the list of sites/servers to check
    # CSV FORMAT: WebsiteURL,WebsitePort,CommonName,PSRemote
    [Parameter(Mandatory=$true,HelpMessage="Full path and name of CSV file containing sites to check")][string]$ServersCSV
)
 
$date = get-date
$DateStr = $Date.ToString("yyyyMMdd")
$csvfile=".\$DateStr" + ".certdata.csv"
$outfile=".\output.html"
 
#check if csv exists, then delete
if (Test-Path $csvfile) {
  Remove-Item $csvfile
}
#check if html exists, then delete
if (Test-Path $outfile) {
  Remove-Item $outfile
}
 
$HtmlHead = '<style>
    body {
        background-color: white;
        font-family:      "Calibri";
    }
 
    table {
        border-width:     1px;
        border-style:     solid;
        border-color:     black;
        border-collapse:  collapse;
        width:            100%;
    }
 
    th {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: #98C6F3;
    }
 
    td {
        border-width:     1px;
        padding:          5px;
        border-style:     solid;
        border-color:     black;
        background-color: White;
    }
 
    tr {
        text-align:       left;
    }
</style>'
 
$arrServers = Import-Csv $ServersCSV
#$arrServers
foreach($objServer in $arrServers) {
    $issuerLong=""
    $certeffective=""
    $certexpire=""
    $servershort=""
    $expiredays=""
    Write-Host ("Server: [{0}] Function: [{1}] - " -f $objServer.ServerName, $objServer.function)
    # -NoNewline
 
    [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
 
    $servername=$objServer.ServerName
    $url = https:// + $servername +"/"
 
    $req = ""
    $output = ""
    $req = [Net.HttpWebRequest]::Create($url)
    #set timeout
    $req.timeout=5000 #5 seconds
    $req.GetResponse() | Out-Null
    $output = [PSCustomObject]@{
    URL = $url
    certeffective = $req.ServicePoint.Certificate.GetEffectiveDateString()
    certexpire = $req.ServicePoint.Certificate.GetExpirationDateString()
    issuerLong=$req.ServicePoint.Certificate.Issuer
    thumb=$req.ServicePoint.Certificate.GetCertHashString()
    }
    $certeffective=$output.certeffective
    $certexpire=$output.certexpire
    $issuerLong=$output.issuerLong
    $thumb=$output.thumb
    switch($issuerLong) {
                    {$issuerLong -match 'comodo'}               { $strIssuer = "Comodo" }
                    {$issuerLong -match 'verisign'}             { $strIssuer = "VeriSign" }
                {$issuerLong -match 'UnitedHealth Group'}       { $strIssuer = "UHG" }
                {$issuerLong -match 'OptumInternalIssuingCA2'}      { $strIssuer = "OptumInternalCA2" }
                {$issuerLong -match $ServerName }           { $strIssuer = "Self Signed" }
                default                         { $strIssuer = $issuerLong }
    }
    $servershort=$servername.split("/")[0]
    $now=get-date
    $expiredays=(New-TimeSpan -Start $now -End $certexpire).Days
    $data = ""
    $data =[pscustomobject]@{
            'ServerName' = $servershort
            'Function' = $objServer.function
            'Issuer' = $strIssuer
            'Effective' = $certeffective
        'Expire' = $certexpire
        'Thumbprint' = $thumb
        'DaysToExpire' = $expiredays
        }
    $data | Export-CSV $csvfile -Append -NoTypeInformation -Force
    #display data for troubleshooting
    #$servershort
    #$objServer.function
    #$issuerLong
    #$strIssuer
    #$certeffective
    write-host "Expire Date: $certexpire"
    #$thumb
   
}
 
import-csv $csvfile | Sort-Object DaysToExpire,Servername |convertto-html -Head $HtmlHead | out-file "$outfile"
