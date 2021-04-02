Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue

#Set Global Variables
$Global:myBasename = (Get-Item -Path $MyInvocation.MyCommand.Name).BaseName
if (!($Global:myBasename)) {$Global:myBasename = 'dummy_myInstall'}
$myInstallName = "$myBasename"
$Global:myLog = $("$env:TEMP\$myBasename" + ".log")
$Global:myWorkDir = $PSScriptRoot
$Global:myRegPackagesPath="HKEY_LOCAL_MACHINE\SOFTWARE\$myInstallName\Packages"
Out-File -FilePath $myLog -InputObject $('<-- ' + (Get-Date).DateTime + "`r`n")
$myVars = @(Get-Variable -Name my*)
Out-File -FilePath $myLog -InputObject $($myVars + "`r`n" + "`r`n") -Append

#Prepare and get my list of files
set-location $myWorkDir
$myPackList = $(Get-Item -Path ".\$($myInstallName)_*.zip").name


function Set-PackageStatus($myCurrentPackageName, $myCurrentExitCode, $myVersionDate) {
    $myRegPath="$myRegPackagesPath\$myCurrentPackageName"
    if (!(Test-Path Registry::$myRegPath)) { New-Item Registry::$myRegPath -Force}
    Set-ItemProperty -path Registry::$myRegPath -Name "ExitCode" -Type String -Value $myCurrentExitCode -Force | Out-Null
    Set-ItemProperty -path Registry::$myRegPath -Name "VersionDate" -Type String -Value $myVersionDate -Force  | Out-Null
}

#Check of existance,ExitCode and VersionDate
function Get-PackageStatus($myCurrentPackageName, $myVersionDate) {
    $myNeedUpdate = $true
    $myRegVersionDate = 0
    $myRegPath="$myRegPackagesPath\$myCurrentPackageName"
    if (!(Test-Path Registry::$myRegPath)) { return $myNeedUpdate }
    
    $myRegExitCode = (Get-ItemPropertyValue -Path Registry::$myRegPath -Name ExitCode)
    $myRegVersionDate = (Get-ItemPropertyValue -Path Registry::$myRegPath -Name VersionDate)

    if (!($myRegExitCode -eq 0 )) { 
        Write-Host "Update $myCurrentPackageName due to LastExitcode was $myRegExitCode"
        return $myNeedUpdate 
    }
    if (($myRegVersionDate) -ge ($myVersionDate)) {
        $myNeedUpdate=$false
        Write-Host "No update needed for $myCurrentPackageName"
    }
    return $myNeedUpdate
}

function Execute-MyPackages {
    foreach ($package in $myPackList) { 
        $myCurrentPackageDir = "$env:TEMP\$package"
        $myPackgeVersion = (Get-ItemProperty .\$package).LastWriteTime.ToString('yyyy-MM-dd')
        $mypackageInfo = "Working on $package"
        $myCheckPackage = (Get-PackageStatus $package $myPackgeVersion)
        if ($myCheckPackage -ieq $false) { continue }
        Write-Host ($mypackageInfo) -ForegroundColor Cyan
        Out-File -FilePath $myLog -InputObject $((Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ": " + $mypackageInfo) -Append
        Out-File -FilePath $myLog -InputObject $('-------------------------------------------------------------------------------' + "`r`n") -Append
        
        Expand-Archive $($package) -DestinationPath "$myCurrentPackageDir" -Force
        if (Test-Path "$myCurrentPackageDir\Install.ps1") {
            $run = .("$myCurrentPackageDir\Install.ps1")
            Write-Host "Exitcode: $LASTEXITCODE" -ForegroundColor Cyan
            Out-File -FilePath $myLog -InputObject $($run) -Append
            Set-PackageStatus $package $LASTEXITCODE $myPackgeVersion
            } else {
            Write-Host ("file not found " + "$myCurrentPackageDir\Install.ps1") -ForegroundColor Yellow
        }
        set-location $myWorkDir
        Start-Sleep -Milliseconds 500
        Remove-Item $myCurrentPackageDir -Recurse -Force
        Write-Host
        Write-Host
        Out-File -FilePath $myLog -InputObject $("`r`n" + "`r`n") -Append
    }
}
    

#Start
Execute-MyPackages
Out-File -FilePath $myLog -InputObject $((Get-Date).DateTime + ' -->') -Append

#OpenLog
.($myLog)
