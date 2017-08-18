<#.DESCRIPTION
   Author: Sebastian Schlesinger 
   Date: 8/17/2017
			Script that will connect to a vSphere environment and move a vm to the spcified folder.
            Results will be logged on a txt file and sent through email
            This example was tested with Windows Server 2012R2 and vSphere 6.0 
            
            Pre-requirements:
            This will require to have PowerCli installed. 
            Define the follwing variables: 
            A)$Logpath = path to save log
            B)$DestFolder = Target VMware folder 
            C)$PCA = Name of the PowerCli action
            D)$Users = Email recipients 
            E)$Fromemail = Source email address for report
            F)$Server = SMTP Server
            G)$VMName = VM that will be moved 

#>

Get-Module -ListAvailable VMware* | Import-Module | Out-Null
##Variables to define:
$LogPath = "C:\logs"
$DestFolder = "Folder Name" # 
$PCA = "Move VM to folder $DestFolder"
#Mail Settings:
$users = "recipient@domain.com" 
$fromemail = "PowerCli@domain.com" 
$server = "smtp.domain.com"
$VMName = "VMName" 


###########################SCRIPT EXECUTION DO NOT MODIFY UNLESS YOU KNOW WHAT YOU ARE DOING###################################

#########Create Transcript of script for logging purposes - Edit the outpath according to your needs
$ErrorActionPreference = "Continue"
$date = get-date -f yyyy-MM-dd
$outPath = "$LogPath\VMFolderMove_$date.txt" # This is the path to save the results
Start-Transcript -path $outPath



##--- Connect to Vcenter
write-verbose "Connecting to Vcenter"   -Verbose 
function Connect-VMware {
##This section contains the commands to connect to Vcenter Edit according to your enviroment---
# ------vSphere Targeting Variables tracked below------
$vCenterInstance = "Vcenter IP"
$vCenterUser = "User"
$vCenterPass = "Password"
# This section logs on to the defined vCenter instance above
Connect-VIServer $vCenterInstance -User $vCenterUser -Password $vCenterPass -WarningAction SilentlyContinue
}
Connect-VMware
Connect-VMware

write-verbose "Moving VM to $DestFolder"   -Verbose 
Get-VM $VMName | Move-VM  -Destination $DestFolder

write-verbose "Checking Resuls"   -Verbose 
$Result = Get-Folder $DestFolder | Get-VM
$Result


##--- Disconnect from Vcenter
write-verbose "Disconnecting from Vcenter"   -Verbose
Disconnect-VIServer -Confirm:$False
 

##--- Transcript Ends
Stop-Transcript

##---Send log information through email
write-verbose "Last step. Sending email report..."   -Verbose
$Body = Get-Content $outPath  | Out-String
$CurrentTime = Get-Date
send-mailmessage -UseSsl  -from $fromemail -to $users -subject "PowerCli Action $PCA Completed at $CurrentTime"  -Body $Body  -priority Normal -smtpServer $server
 