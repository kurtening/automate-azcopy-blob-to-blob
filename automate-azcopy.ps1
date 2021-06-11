
<#
.SYNOPSIS
  Azcopy automation
.DESCRIPTION
  This is a powershell script that automates the azcopy from an MFT server to a storage account
.OUTPUTS Log File
  The script log file is stored in $logfile
.NOTES
  Version:        1.0
  Author:         Flores, Kurt Ranzel
  Creation Date:  06/12/2021
  Purpose/Change: Initial script development
.EXAMPLE
  Run as script or add to task scheduler

  Run in powershell terminal: ./automate-azcopy.ps1
  
#>


#----------------------------------------------------------[Declarations]----------------------------------------------------------
$MFTSourceP = "" #declare the folder of the source files that will be transferred
$logfile = "$($MFTSourceP)\logs\logfile_$(get-date -f yyyyMMddhhmmss).txt" #modify as desired and make sure the path exists
$ArchiveDir = "$($MFTSourceP)\archive\" #make sure tha path exists
$Sast = "/?sv=2020-02-10&ss=bfqt&srt=sco&sp=rwdlacuptfx&se=2022-01-01T03:02:43Z&st=2021-06-11T19:02:43Z&spr=https&sig=8CBsCBOgrxOMFhTuuTX3L1Gxw60NuOqz6yxuuYDPK6g%3D" #declare your SAS token after the "/" (make sure not to remove the "/") best practice is to use key-vault or secure string
$containerUrl = "https://rgkrof2021testdevstdsa.blob.core.windows.net/kroftest" #declare storage URL here
$files = Get-ChildItem -Path $MFTSourceP #Get the objects to be copied (feel free to filter these objects)

#-----------------------------------------------------------[Function]------------------------------------------------------------

Function DoAzcopy {
  param(
    [Parameter(Mandatory)]
    [string] $SourceF
  )
  Write-Host "Executing Azcopy for $SourceF to $containerUrl"
  Write-Output "Executing Azcopy for $SourceF to $containerUrl" >>$logfile
  azcopy.exe copy $SourceF $containerUrl$Sast --overwrite=true >> $logfile  #change overwrite mode as desired
  if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully moved $SourceF to target Blob container."
    Move-Item -Path $SourceF -Destination "$ArchiveDir$SourceF"
    Write-Host "Moved $SourceF to Archive"
    Write-Output "Moved $SourceF to Archive" >> $logfile
  } else {
    Write-Error "Failed to move $SourceF to target container."
  }

}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
Set-Location $MFTSourceP

foreach ($item in $files)
{DoAzcopy $item}