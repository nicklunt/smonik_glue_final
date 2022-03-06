<powershell>

if( -not (Test-Path C:\UserDataLogs -PathType Container) )
{
    New-Item -Name UserDataLogs -Path C:\ -ItemType directory
}

Start-Transcript -Path "C:\UserDataLogs\userdata_exec.log" -append
Write-Verbose "Logging to C:\UserDataLogs\userdata_exec.log" -Verbose
Write-Verbose "$(date) Useradata Started" -Verbose

# EC2 Windows Windows Logs: C:\ProgramData\Amazon\EC2-Windows\Launch\Log\
# Meta-data on Windows: Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/
# Install aws cli: msiexec /i path/to/awscli.msi /qn

# Check for 3 disks, OS, Data, Backup
while ((Get-Disk).Number.Count -ne 3)
{
    Get-Disk
    Write-Host "Waiting for disks"
    Start-Sleep -Seconds 5
}

$Disk1 = Get-Disk -Number 1
$Disk2 = Get-Disk -Number 2

if( ($Disk1.PartitionStyle -eq "RAW") -and ($Disk1.Size / 1024 / 1024 /1024 -eq 20) )
{
    # Found 20GB F Drive
    Initialize-Disk -Number 1 -PartitionStyle GPT
    New-Partition -DiskNumber 1 -DriveLetter F -UseMaximumSize
    Format-Volume -DriveLetter F -FileSystem NTFS -NewFileSystemLabel "Backup" -Force -Confirm:$false
}
elseif ( ($Disk1.PartitionStyle -eq "RAW") -and ($Disk1.Size / 1024 / 1024 /1024 -eq 10) )
{
    # Found 10GB G Drive
    Initialize-Disk -Number 1 -PartitionStyle GPT
    New-Partition -DiskNumber 1 -DriveLetter G -UseMaximumSize
    Format-Volume -DriveLetter G -FileSystem NTFS -NewFileSystemLabel "Data" -Force -Confirm:$false
}

if( ($Disk2.PartitionStyle -eq "RAW") -and ($Disk2.Size / 1024 / 1024 /1024 -eq 20) )
{
    # Found 20GB F Drive
    Initialize-Disk -Number 2 -PartitionStyle GPT
    New-Partition -DiskNumber 2 -DriveLetter F -UseMaximumSize
    Format-Volume -DriveLetter F -FileSystem NTFS -NewFileSystemLabel "Backup" -Force -Confirm:$false
}
elseif ( ($Disk2.PartitionStyle -eq "RAW") -and ($Disk2.Size / 1024 / 1024 /1024 -eq 10) )
{
    # Found 10GB G Drive
    Initialize-Disk -Number 2 -PartitionStyle GPT
    New-Partition -DiskNumber 2 -DriveLetter G -UseMaximumSize
    Format-Volume -DriveLetter G -FileSystem NTFS -NewFileSystemLabel "Data" -Force -Confirm:$false
}

Write-Verbose "$(date) Userdata Finished"
Stop-Transcript

</powershell>