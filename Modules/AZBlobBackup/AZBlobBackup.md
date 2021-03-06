# AZBlobBackup Module
## AZBlobBackup
### Synopsis
This module contains tools for compress folders and upload them to Azure Blob Storage. It supports 7z and zip compression algorithms. It has also diff backup feature. This feature can only be used with 7z compression. 

### Install (via PSGallery)
```powershell
PS> Install-Module -Name AZBlobBackup
```

### Syntax
```powershell

AZBlobBackup [-OutputFolder] <String> [-InputFolders] <Object> [-DiffBackup] [-AZUpload] [[-AZContainerName] <String>] 
[[-AZContext] <IStorageContext>] [[-AZResourceGroupName] <String>] [[-AZStorageAccountName] <String>] 
[-AZAcquireLease] [-Force] [[-ArchiveFormat] <String>] [[-SevenZPath] <String>] [[-SevenZUpdateSwitch] <String>] 
[[-LogFile] <String>] [<CommonParameters>]
```

### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>OutputFolder</nobr> |  | Specifies the output folder for compressed backups | true | false |  |
| <nobr>InputFolders</nobr> |  | Input folders for backup. It must be specified in "Name/Value" dictionary type. Ex: @\{"Folder1"="C:\\Folder1", "Folder2"="C:\\Folder2"\} | true | false | @\{\} |
| <nobr>DiffBackup</nobr> |  | Specifies only differential backup will be made. This option requires "7z" archive format and an full backup had to made first. | false | false | False |
| <nobr>AZUpload</nobr> |  | Specifies if the compressed file upload to Azure Blob Storage or not. | false | false | False |
| <nobr>AZContainerName</nobr> |  | Specifies Azure Blob Storage container name. It will be generated, if it is omitted. | false | false |  |
| <nobr>AZContext</nobr> |  | Specifies Azure Blob Storage account context. It can be generated, if Azure Context Autosave option is enabled. \(Enable-AzureRmContextAutosave\) | false | false |  |
| <nobr>AZResourceGroupName</nobr> |  | Specifies Azure Blob Storage resource group name. If AZContext parameter is specified, It can be omitted. | false | false |  |
| <nobr>AZStorageAccountName</nobr> |  | Specifies Azure Blob Storage account name. If AZContext parameter is specified, It can be omitted. | false | false |  |
| <nobr>AZAcquireLease</nobr> |  | Specifies Azure Blob Storage leasing will be acquired after upload. | false | false | False |
| <nobr>Force</nobr> |  | Specifies previous backup for the same folder will be deleted. | false | false | False |
| <nobr>ArchiveFormat</nobr> |  | Specifies the archive format. Possible options are "7z" and "zip". Default option is "7z". 7z setup has to be installed. | false | false | 7z |
| <nobr>SevenZPath</nobr> |  | Specifies the 7z executable path. Default value is 'C:\\Program Files\\7-Zip\\7z.exe' | false | false | C:\\Program Files\\7-Zip\\7z.exe |
| <nobr>SevenZUpdateSwitch</nobr> |  | Specifies the 7z differential backup switches. Default value is '-up0q0r2x2y2z0w2\!' | false | false | -up0q0r2x2y2z0w2\! |
| <nobr>LogFile</nobr> |  | Log file for log output. Default value is 'azblobbackup.log | false | false | "$PSScriptRoot\\azblobbackup.log" |

### Inputs
 - None

### Outputs
 - None

### Examples
**EXAMPLE 1**
```powershell
AZBlobBackup -OutputFolder C:\Backup -InputFolders @{"Test"="C:\Test"}
```

**EXAMPLE 2**
```powershell
AZBlobBackup -OutputFolder C:\Backup -InputFolders @{"Test"="C:\Test"} -AZUpload -AZResourceGroupName StorageResGroup -AZAcquireLease -AZStorageAccountName TestStorageAccount -Force
```

**EXAMPLE 3**
```powershell
AZBlobBackup -OutputFolder C:\Backup -InputFolders @{"Test"="C:\Test"} -AZUpload -AZResourceGroupName StorageResGroup -AZAcquireLease -AZStorageAccountName TestStorageAccount -DiffBackup
```

**EXAMPLE 4**
```powershell
AZBlobBackup -OutputFolder C:\Backup -InputFolders @{"Test"="C:\Test"} -ArchiveFormat zip
```