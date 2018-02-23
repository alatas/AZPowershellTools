<#
.SYNOPSIS

Compress folders and upload them to Azure Blob Storage.

.DESCRIPTION

This function compress input folders and upload them to Azure Blob Storage. It supports 7z and zip compression algorithms.
It has also diff backup feature. This feature can only be used with 7z compression. 

.PARAMETER OutputFolder
Specifies the output folder for compressed backups

.PARAMETER InputFolders
Input folders for backup. It must be specified in "Name/Value" dictionary type. Ex: @{"Folder1"="C:\Folder1", "Folder2"="C:\Folder2"}

.PARAMETER ArchiveFormat
Specifies the archive format. Possible options are "7z" and "zip". Default option is "7z". 7z setup has to be installed.

.PARAMETER DiffBackup
Specifies only differential backup will be made. This option requires "7z" archive format and an full backup had to made first.

.PARAMETER Force
Specifies previous backup for the same folder will be deleted.

.PARAMETER AZAcquireLease
Specifies Azure Blob Storage leasing will be acquired after upload.

.PARAMETER AZContainerName
Specifies Azure Blob Storage container name. It will be generated, if it is omitted.

.PARAMETER AZContext
Specifies Azure Blob Storage account context. It can be generated, if Azure Context Autosave option is enabled. (Enable-AzureRmContextAutosave)

.PARAMETER AZResourceGroupName
Specifies Azure Blob Storage resource group name. If AZContext parameter is specified, It can be omitted.

.PARAMETER AZStorageAccountName
Specifies Azure Blob Storage account name. If AZContext parameter is specified, It can be omitted.

.PARAMETER AZUpload
Specifies if the compressed file upload to Azure Blob Storage or not.

.PARAMETER LogFile
Log file for log output. Default value is 'azblobbackup.log

.PARAMETER SevenZPath
Specifies the 7z executable path. Default value is 'C:\Program Files\7-Zip\7z.exe'

.PARAMETER SevenZUpdateSwitch
Specifies the 7z differential backup switches. Default value is '-up0q0r2x2y2z0w2!'

.PARAMETER CommonParameters
This cmdlet supports the common parameters: Verbose, Debug, ErrorAction, ErrorVariable, WarningAction, WarningVariable,
OutBuffer, PipelineVariable, and OutVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

.INPUTS

None

.OUTPUTS

None

.EXAMPLE

C:\PS>AZBlobBackup -OutputFolder C:\Backup -InputFolders @{"Test"="C:\Test"}

.EXAMPLE

C:\PS>AZBlobBackup -OutputFolder C:\Backup -InputFolders @{"Test"="C:\Test"} -AZUpload -AZResourceGroupName StorageResGroup -AZAcquireLease -AZStorageAccountName TestStorageAccount -Force

.EXAMPLE

C:\PS>AZBlobBackup -OutputFolder C:\Backup -InputFolders @{"Test"="C:\Test"} -AZUpload -AZResourceGroupName StorageResGroup -AZAcquireLease -AZStorageAccountName TestStorageAccount -DiffBackup

.EXAMPLE

C:\PS>AZBlobBackup -OutputFolder C:\Backup -InputFolders @{"Test"="C:\Test"} -ArchiveFormat zip

.LINK

https://github.com/alatas/AZPowershellTools

#>
function AZBlobBackup {
  param(
    [Parameter(Mandatory = $True)][string]$OutputFolder,
    [Parameter(Mandatory = $True)]$InputFolders = @{},
    [switch]$DiffBackup = $false,
    [switch]$AZUpload = $false,
    [string]$AZContainerName = "",
    [Microsoft.Azure.Commands.Common.Authentication.Abstractions.IStorageContext]$AZContext = $null,
    [string]$AZResourceGroupName = "",
    [string]$AZStorageAccountName = "",
    [switch]$AZAcquireLease = $false,
    [switch]$Force = $false,
    [ValidateSet("7z", "zip")][string]$ArchiveFormat = "7z",
    [string]$SevenZPath = "C:\Program Files\7-Zip\7z.exe",  
    [string]$SevenZUpdateSwitch = "-up0q0r2x2y2z0w2!",
    [string]$LogFile = "$PSScriptRoot\azblobbackup.log" 
  )

  try {
    
    if ($ArchiveFormat -eq "zip" -and $DiffBackup) {
      Throw "Differential backup can only be used with 7z format"
    }
    
    if ($ArchiveFormat -eq "7z" -and -not (Test-Path $SevenZPath)) {
      Throw "7z cannot be found. Please install 7z and pass executable path to '-SevenZPath' parameter"
    }
      
    if ($AZUpload) {
      #Creating Blob Container
      Import-Module AzureRM -NoClobber -ErrorAction Stop
      if ($AZContext -eq $null) {$AZContext = (Get-AzureRmStorageAccount -ResourceGroupName $AZResourceGroupName -Name $AZStorageAccountName).Context}
      if ($AZContainerName -eq "") {$AZContainerName = "azblobbackup-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')-$(if($DiffBackup){"diff"}else{"full"})"}
      New-AzureStorageContainer -Name $AZContainerName -Permission Off -Context $AZContext | Out-Null
    }
      
    foreach ($Key in $InputFolders.Keys) {
      $InputFolder = $InputFolders[$Key]
      Write-Log -Level Info -Message "`nProcessing $Key - $InputFolder"
    
      if (-not $DiffBackup) {
        #Fullbackup
        $OutputFile = "$OutputFolder\$Key-Full.$ArchiveFormat"
        $Name = "$Key-Full"
    
        if ($Force) {Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue}
        
        Write-Log -Level Info -Message "Compressing full backup to $OutputFile"
        if ($ArchiveFormat -eq "7z") {
          & $SevenZPath a -mhe -ms=off -ssw -mx= -t7z "$OutputFile" "$InputFolder" | Out-Null
        } 
        else {
          Compress-Archive -Path "$InputFolder" -DestinationPath "$OutputFile" | Out-Null
        }
      }
      else {
        #Diffbackup
        $LatestFullBackup = Get-Item $OutputFolder\$Key-Full.7z -ErrorAction SilentlyContinue | Sort-Object -Descending | Select-Object -First 1 -ExpandProperty FullName 
        if (!$LatestFullBackup) {
          Throw "Latest Full Backup cannot be found -> $Key"
        }
        Write-Log -Level Info -Message "Found latest full backup $LatestFullBackup"
    
        $OutputFile = "$OutputFolder\$Key-Diff.7z"
        $Name = "$Key-Diff"
        if ($Force) {Remove-Item $OutputFile -Force -ErrorAction SilentlyContinue}
    
        Write-Log -Level Info -Message "Compressing diff backup to $OutputFile"
        & $SevenZPath u -mhe -ms=off -ssw "$LatestFullBackup" "$InputFolder" -mx=7 -t7z -u- $SevenZUpdateSwitch$OutputFile | Out-Null
      }
    
      if ($AZUpload) {
        #Blob upload
        Write-Log -Level Info -Message "Starting to upload"
    
        Set-AzureStorageBlobContent -File $OutputFile -Container $AZContainerName -Blob $Key -Context $AZContext -Force:$Force | Out-Null
        $blob = Get-AzureStorageBlob -Container $AZContainerName -Blob $Key -Context $AZContext -ErrorAction Stop
        
        Write-Log -Level Info -Message "Blob upload Complete - $($blob.ICloudBlob.StorageUri.PrimaryUri.ToString())"
        if ($AZAcquireLease) {
          $lease = $blob.ICloudBlob.AcquireLease($null, $null, $null, $null, $null)
          "Blob lease acquired - $lease "
        }
      }
    }
    
    if ($AZUpload -and $AZAcquireLease) {
      #Blob Container Lease
      $container = Get-AzureStorageContainer -Container $AZContainerName -Context $AZContext -ErrorAction Stop
      $lease = $container.CloudBlobContainer.AcquireLease($null, $null, $null, $null, $null)
      Write-Log -Level Info -Message "Container lease acquired - $lease"
    }
    
    Write-Log -Level Info -Message "`nCompleted!"
  }
  catch {
    Write-Log -Level Error -Message "Exception:`n$($_.Exception.GetType().FullName)`n$($_.Exception.Message)`n$($_.Exception.StackTrace)"
  }
}
  
  
function Write-Log {
  param
  (
    [Parameter(Mandatory = $true)][string]$Message,
    [ValidateSet("Error", "Warn", "Info")] [string]$Level = "Info"
  )
    
  $LogDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  switch ($Level) {
    'Error' {
      Write-Error $Message
      $LevelText = 'ERROR:'
    }
    'Warn' {
      Write-Warning $Message
      $LevelText = 'WARNING:'
    }
    'Info' {
      Write-Host $Message
      $LevelText = 'INFO:'
    }
  }
    
  "$LogDate $LevelText $Message" | Out-File -FilePath $LogFile -Append
}
  
Export-ModuleMember AZBlobBackup