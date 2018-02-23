# Azure PowerShell Tools
## What is Azure / Powershell?
If you are literally asking this question, you are probably in the wrong place. But in short, [Azure](https://azure.microsoft.com) is a cloud provider *(not the cloud in the sky, it's someone else's computer that you rent)* owned by Microsoft *(yes, Windows and Bill Gates)*.

And [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/getting-started/getting-started-with-windows-powershell?view=powershell-6) is a command-line interface *(this is what it feels like you are hacking The Matrix, but you are probably copying a folder)* owned by Microsoft *(again, but open-sourced this time)*.

## What are these tools for?
These tools were developed for different purposes, but all of them helps you for automate some processes or tasks in Azure environment.

## Prerequisites
All the tools were published in PSGallery. PSGallery is a package manager for powershell scripting. 

When you want to use these tools, you may use one-liner powershell command for install the tool and its dependencies. Otherwise, you may also download the tool and use it without installing. In that way, you also have to find and install its dependencies manually.

If you want to use PSGallery, you better check the [prerequisites](https://docs.microsoft.com/en-us/powershell/gallery/psgallery/psgallery_gettingstarted#requirements) and complete them before.

## Tools Included
### [AZBlobBackup](Modules/AZBlobBackup/AZBlobBackup.md)
This module contains tools for compress folders and upload them to Azure Blob Storage. It supports 7z and zip compression algorithms. It has also diff backup feature. This feature can only be used with 7z compression. 