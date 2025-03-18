Function Get-LenovoLegionFirmware{

    <#
        .DESCRIPTION

            Checks for available downloads from the Lenovo firmware web page.

            If there is a version available that is higher than the version specified,
            you can optionally download the desired package. You will be prompted to
            answer y/n to download.

            This script assumes you are running PowerShell 7 on Linux. Further, we assume
            you have some facility to install the Windows-based firmware update from Lenovo.
            The firmware update is a `.exe` file, so you can save it to USB and then boot into
            your Windows partition to install it. Or pretend to install Windows and press SHIFT-F10
            to access a terminal while in the Windows Out of Box Experience (OOBE).

            The recommendation is to set the BIOS to recommended defaults before and after updating.
            Be aware that Secure Boot is the new default, which it was not perhaps when you first purchased
            your machine or installed your previous firmware.

            Be aware that changes to Secure Boot and firmware updates in general can leave your system unbootable.
            Always take a full backup using something like a Lacie USB drive or similar.
        
        .NOTES
            Script:  Get-LenovoLegionFirmware.ps1
            Author:  Hyper Mike Labs
            Github:  site:github.com user:mikenizo808
            License: MIT 2025
            Tips:    - While this script does not update your BIOS, it does download it for you.
                     - Be sure to get a full backup of your system before updating the BIOS.
                     - You may want a USB Thumbdrive to copy the Lenovo firmware `.exe` file
                     - Lenovo BIOS updates require Windows to install.
                     - Confusingly this script is written for Linux, I know, We expect you to notice and download the bits on Linux, but apply them in Windows.
                     - We just use "wget" to download the bits. Feel free to enahance as needed.

        .EXAMPLE
        #initial setup
        #
        #Optionally determine the current BIOS version.
        
            # show all info, including serial number
            sudo dmidecode -t bios

            #show just the version
            sudo dmidecode -t bios | grep -i version

            #Note: Then you can use the info learned to fill out the parameters for "Get-LenovoLegionFirmware" such as "CurrentVersion" and "FirmwareType".


        .EXAMPLE
        #Legion 5 example
        Import-Module ~/Scripts/Get-LenovoLegionFirmware.ps1 -Force
        Get-LenovoLegionFirmware -CurrentVersion 37 -FirmwareType hhcnXXww

        This example machine is a Legion 5 running "hhcn37ww" so we populate `CurrentVersion` with a value of `37`.
        Then we specify the `FirmwareType` of `hhcnXXww`.

        .EXAMPLE
        #Legion 7 example
        Import-Module ~/Scripts/Get-LenovoLegionFirmware.ps1 -Force
        Get-LenovoLegionFirmware -CurrentVersion 37 -FirmwareType nscnXXww

        This example machine is a Legion 7 running "nscn36ww" so we populate `CurrentVersion` with a value of `36`.
        Then we specify the `FirmwareType` of `nscnXXww`.

    #>

    [CmdletBinding(DefaultParameterSetName='By FirmwareType')]

    Param(

        #Integer. Enter your current version as a short number such as 37. The script then combines this with the value from the FirmwareType parameter.
        #Optionally set this to one less than your current version to test what the download experience would be.
        [Alias('Version')]
        [int]$CurrentVersion,
        
        #String. Type or tab-complete the naming convention `hhcnXXww` or `nscnXXww`. Do not solve for 'XX' as this simply denotes the nomenclature.
        [Parameter(ParameterSetName='By FirmwareType')]
        [ValidateSet('hhcnXXww','nscnXXww')]
        [Alias('Nomenclature')]
        [string]$FirmwareType,

        #String. Optionally enter a custom value to describe the firmware naming convention. We expect the string to have the characters "XX", so we can replace that with the version number.
        [Parameter(ParameterSetName='By CustomType')]
        [string]$CustomType,

        #String. The URL to the Lenovo firmware download page. There should be no need to change this. We later append the version of readme and firmware (BIOS) to lookup.
        [Alias('Url')]
        [string]$Uri = 'https://download.lenovo.com/consumer/mobiles/',

        #String. Optionally show extra runtime information. This uses the verbose stream even if Verbose is not populated.
        [ValidateSet('ShowVars','ShowVarsAndPause','None')]
        [string]$ExtraInfo

    )
    Process{

        ## Handle version number
        If($CurrentVersion){
            [int]$intCurrentVersion = $CurrentVersion
        }
        Else{
            Write-Warning -Message 'Please populate the "CurrentVersion" parameter and try again.'
            return
        }

        ## Theorize the next version
        [int]$intNextUpdate = ($intCurrentVersion + 1)

        ## Handle firmware naming style
        if($FirmwareType){
            $strFirmwareType = $FirmwareType
        }
        Else{
            #Handle user provided input
            $strFirmwareType = [System.Management.Automation.Language.CodeGeneration]::EscapeSingleQuotedStringContent($CustomType)
        }

        ## String handling
        $strRawText = $strFirmwareType -split 'XX'
        $strPrefix = $strRawText[0]
        $strSuffix = $strRawText[1]

        ## optional debug
        if($ExtraInfo -eq 'ShowVars' -or $ExtraInfo -eq 'ShowVarsAndPause'){
            Write-Verbose -Message 'The value of prefix is:' -Verbose
            Write-Verbose -Message ($strPrefix | Out-String) -Verbose
            Write-Verbose -Message 'The value of suffix is:' -Verbose
            Write-Verbose -Message ($strSuffix | Out-String) -Verbose
        
            If($ExtraInfo -eq 'ShowVarsAndPause'){
                Pause
            }
        }

        ## Handle current version name
        ##
        ## This is the assumed version of the local system, though user can enter
        ## a different number when populating the `CurrentVersion` parameter.
        $strCurrentVersionName = ('{0}{1}{2}' -f $strPrefix,$intCurrentVersion,$strSuffix)
        
        ## Theorize name of future readme
        $strReadmeName = ('{0}{1}{2}.txt' -f $strPrefix,$intNextUpdate,$strSuffix)

        ## Theorize name of future firmware
        $strFirmwareName = ('{0}{1}{2}.exe' -f $strPrefix,$intNextUpdate,$strSuffix)

        ## optional debug
        if($ExtraInfo -eq 'ShowVars' -or $ExtraInfo -eq 'ShowVarsAndPause'){
            Write-Verbose -Message 'The value of future readme is:' -Verbose
            Write-Verbose -Message ($strReadmeName | Out-String) -Verbose
            Write-Verbose -Message 'The value of future firmware is:' -Verbose
            Write-Verbose -Message ($strFirmwareName | Out-String) -Verbose

            If($ExtraInfo -eq 'ShowVarsAndPause'){
                Pause
            }
        }
        
        ## URL Handling
        $strReadMeURI = ('https://download.lenovo.com/consumer/mobiles/{0}' -f $strReadmeName)
        $strFirmwareURI = ('https://download.lenovo.com/consumer/mobiles/{0}' -f $strFirmwareName)

        ## Check if a new readme exists
        try{
            $exists = Invoke-WebRequest -Uri $strReadMeURI -ErrorAction Ignore
        }
        catch{
            $exists = $false
        }

        ## optional debug
        if($ExtraInfo -eq 'ShowVars' -or $ExtraInfo -eq 'ShowVarsAndPause'){
            Write-Verbose -Message 'The value of exists for web readme is:' -Verbose
            Write-Verbose -Message ($exists | Out-String) -Verbose
            
            If($ExtraInfo -eq 'ShowVarsAndPause'){
                Pause
            }
        }

        ## If a new firmware is available, offer to download
        if($exists){
            Write-Host ('A new BIOS version is available ({0})' -f $strFirmwareName) -ForegroundColor Cyan
            Write-Host ''
            $promptUser = Read-Host 'Would you like to download it now? (yes/no)'
            if($promptUser -like "y*"){

                ## Change directory
                Set-Location ~/Downloads
                
                ## Get the readme file if available
                try{
                    wget $strReadMeURI
                }
                catch{
                    Write-Warning -Message ('The readme resource ({0}) has not been released yet or is unavailable' -f $strReadmeName)
                }

                ## Get the firmware file if available
                try{
                    wget $strFirmwareURI
                }
                catch{
                    Write-Warning -Message ('The firmware resource ({0}) has not been released yet or is unavailable' -f $strFirmwareName)
                }
            }
            Else{
                Write-Host ''
                Write-Host 'no action taken.'
                Write-Host ''
            }
        }
        Else{
            Write-Host ''
            Write-Host ('BIOS is up to date, running "{0}"' -f $strCurrentVersionName) -ForegroundColor Green
            Write-Host ''
        }

    }#End Process
}#End Function