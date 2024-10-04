#-------------------------------------------------------------------------------------------------------------------------------------------------#
#          _             _                _            _            _   _         _                 _          _          _             _         #
#         / /\          /\_\             /\ \         /\ \         /\_\/\_\ _    / /\              /\ \       /\ \       /\ \     _    /\ \       #
#        / /  \        / / /         _   \_\ \       /  \ \       / / / / //\_\ / /  \             \_\ \      \ \ \     /  \ \   /\_\ /  \ \      #
#       / / /\ \       \ \ \__      /\_\ /\__ \     / /\ \ \     /\ \/ \ \/ / // / /\ \            /\__ \     /\ \_\   / /\ \ \_/ / // /\ \_\     #
#      / / /\ \ \       \ \___\    / / // /_ \ \   / / /\ \ \   /  \____\__/ // / /\ \ \          / /_ \ \   / /\/_/  / / /\ \___/ // / /\/_/     #
#     / / /  \ \ \       \__  /   / / // / /\ \ \ / / /  \ \_\ / /\/________// / /  \ \ \        / / /\ \ \ / / /    / / /  \/____// / / ______   #
#    / / /___/ /\ \      / / /   / / // / /  \/_// / /   / / // / /\/_// / // / /___/ /\ \      / / /  \/_// / /    / / /    / / // / / /\_____\  #
#   / / /_____/ /\ \    / / /   / / // / /      / / /   / / // / /    / / // / /_____/ /\ \    / / /      / / /    / / /    / / // / /  \/____ /  #
#  / /_________/\ \ \  / / /___/ / // / /      / / /___/ / // / /    / / // /_________/\ \ \  / / /   ___/ / /__  / / /    / / // / /_____/ / /   #
# / / /_       __\ \_\/ / /____\/ //_/ /      / / /____\/ / \/_/    / / // / /_       __\ \_\/_/ /   /\__\/_/___\/ / /    / / // / /______\/ /    #
# \_\___\     /____/_/\/_________/ \_\/       \/_________/          \/_/ \_\___\     /____/_/\_\/    \/_________/\/_/     \/_/ \/___________/     #
#                            _              _        _            _       _                _        _    _        _                               #
#                           / /\      _    /\ \     /\ \         / /\    / /\             /\ \     /\ \ /\ \     /\_\                             #
#                          / / /    / /\   \ \ \    \_\ \       / / /   / / /             \ \ \   /  \ \\ \ \   / / /                             #
#                         / / /    / / /   /\ \_\   /\__ \     / /_/   / / /              /\ \_\ / /\ \ \\ \ \_/ / /                              #
#                        / / /_   / / /   / /\/_/  / /_ \ \   / /\ \__/ / /              / /\/_// / /\ \ \\ \___/ /                               #
#                       / /_//_/\/ / /   / / /    / / /\ \ \ / /\ \___\/ /      _       / / /  / / /  \ \_\\ \ \_/                                #
#                      / _______/\/ /   / / /    / / /  \/_// / /\/___/ /      /\ \    / / /  / / /   / / / \ \ \                                 #
#                     / /  \____\  /   / / /    / / /      / / /   / / /       \ \_\  / / /  / / /   / / /   \ \ \                                #
#                    /_/ /\ \ /\ \/___/ / /__  / / /      / / /   / / /        / / /_/ / /  / / /___/ / /     \ \ \                               #
#                    \_\//_/ /_/ //\__\/_/___\/_/ /      / / /   / / /        / / /__\/ /  / / /____\/ /       \ \_\                              #
#                        \_\/\_\/ \/_________/\_\/       \/_/    \/_/         \/_______/   \/_________/         \/_/                              #
#                                                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------------------#
# Disclaimer:                                                                                                                                     #
#                                                                                                                                                 #
# This script comes with no guarantees. The cmdlets in this script functioned as is on the moment of creating the script.                         #
# It is possible that during the lifecycle of the product this script is intended for, updates were performed to the systems and the script       #
# might not, or might to some extent, no longer function.                                                                                         #
#                                                                                                                                                 #
# Therefor, I would suggest running the script in a test environment first, cmdlet per cmdlet, before effectively running it in production        #
# environments.                                                                                                                                   #
#                                                                                                                                                 #
# Created by Leon Moris                                                                                                                           #
# Website: www.switchtojoy.be                                                                                                                     #
# Github: https://github.com/Joy-Leon                                                                                                             #
#-------------------------------------------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------------------- NOTE ---------------------------------------------------------------------#

#---------------------------------------------------------------------- VARS ---------------------------------------------------------------------#

$logfile = "C:\Joy\logfile.txt"

#---------------------------------------------------------------------- FUNC ---------------------------------------------------------------------#
function func_logging {   
    param ($string) 
    func_writeok $string
    Start-Sleep -Seconds 3 
    return "[{0:dd/MM/yy} {0:HH:mm:ss}] $string" -f (Get-Date)  | Out-File $logfile -append
}
function func_writeok {
    param ($string)
    write-host ""
    write-host $string -f green
}
function func_writenok {
    param ($string)
    write-host ""
    write-host $string -f red
}

function func_directory {
    param($Path)
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | out-null
    }
}

#---------------------------------------------------------------------- DEVS ---------------------------------------------------------------------#

#---------------------------------------------------------------------- PROD ---------------------------------------------------------------------#

#------------------ Preparations for Logfile -------------------#

func_directory "C:\Joy"

if (Test-Path $logfile) {
    if (Test-Path "$logfile.old") {
        Remove-Item "$logfile.old"
    }
    move-item $logfile -destination "$logfile-old.txt"
}
new-item $logfile | func_logging "A logfile has been created at $logfile"

#---------------------- Listing all Shares ---------------------#

$Shares = get-smbshare

$SharesReport = @()

Foreach ($Share in $Shares) {
    $Acl = Get-Acl -Path $Share.path
    foreach ($Access in $acl.Access)
        {
            $Properties = [ordered]@{
                'Share Name'=$Share.name;
                'Share Path'=$Share.path;
                'ADGroup or User'=$Access.IdentityReference;
                'Permissions'=$Access.FileSystemRights;
                'Inherited'=$Access.IsInherited}
            $SharesReport += New-Object -TypeName PSObject -Property $Properties
        }
}
$SharesReport | Export-Csv -path "C:\temp\Shares.csv" -NoTypeInformation

#-------------------- Listing all Subfolders -------------------#

$FolderPath = get-childitem -Directory -Path "E:\Data" -Recurse -Force

$Report = @()

Foreach ($Folder in $FolderPath) {
    $Acl = Get-Acl -Path $Folder.FullName
    foreach ($Access in $acl.Access)
        {
            $Properties = [ordered]@{
                'FolderName'=$Folder.FullName;
                'ADGroup or User'=$Access.IdentityReference;
                'Permissions'=$Access.FileSystemRights;
                'Inherited'=$Access.IsInherited}
            $Report += New-Object -TypeName PSObject -Property $Properties
        }
}
$Report | Export-Csv -path "C:\temp\FolderPermissions.csv" -NoTypeInformation
