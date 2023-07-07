# Pull active directory custom attributes

# Run on a server with AD snap-in installed
Import-Module ActiveDirectory

# Initialize variables
$output = "division.txt"
$userlist = Get-Content userlist.txt

# Iterate through the user list
$userlist | ForEach-Object {
    $user = Get-ADUser -Identity $_ -Properties company-division, company-contractorvendorname, company-externalsegment, company-business, company-internalsegment, company-IdentityManagement-Mail

    # Clean up division names with commas
    $division = $user.'company-division' -replace ',', ''
    $contractor = $user.'company-contractorvendorname' -replace ',', ''
    $externalsegment = $user.'company-externalsegment' -replace ',', ''
    $business = $user.'company-business' -replace ',', ''
    $internalsegment = $user.'company-internalsegment' -replace ',', ''
    $mgmtmail = $user.'company-IdentityManagement-Mail'
    $maildomain = $mgmtmail.Split("@")[1]

    # Write data to the output file
    Add-Content -Path $output -Value "$_,$division,$contractor,$externalsegment,$business,$internalsegment,$maildomain"
}
