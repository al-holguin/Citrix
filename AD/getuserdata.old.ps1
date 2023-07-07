#Pull active directory custom atributes

#run on server with AD snapin installed
import-module activedirectory

#initialize variables
$output="division.txt"
$userlist=get-content userlist.txt
$division=""
$contractor=""
$externalsegment=""
$business=""
$internalsegment=""
$mgmtmail=""
$maildomain=""
#slow method with large datasets, but reliable results
$userlist | foreeach {division=Get-ADUser -identity $_ - properties company-division | select -expand company-division
  #clean up division names with commas
  $division=$division -replace ',',''
  $contractor=Get-ADUser -Identity $_ - properties company-contractorvendorname| select -expand company-contractorvendorname
  #clean up named with commas
  $contractor=$contracot -replace ',',''
  $externalsegment=Get-ADuser -Identity $_ -properties company-externalsegment|select -expand company-externalsegment
  $externalsegment=$externalsegment -replace ',',''
  $business=Get-ADUser -Identity $_ -properties company-business | select -expand company-business
  $business=$business -replace ',',''
  $internalsegment=Get-ADUser -Identity $_ -properties company-internalsegment | select -expand company-internalsegment
  $internalsegment=$internalsegment -replace ',',''
  $mgmtmail=Get-ADUser -identity $_ -properties company-IdentityManagement-Mail | select -expand company-IdentityManagement-Mail
  $maildomain=$mgmtmail.split("@")[1]

  #write data
  add-content $output "$_,$division,$contractor,$externalsegment,$business,$internalsegment,$maildomain"
  #initialize variables again
  $division=""
  $contractor=""
  $externalsegment=""
  $business=""
  $internalsegment=""
  $mgmtmail=""
  $maildomain=""
}
