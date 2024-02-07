# PowerShell script to install forensic tools with error handling

# Function to log messages
Function Log-Message {
    Param (
        [string]$Message,
        [string]$Type = "INFO", # Default type is INFO, other types could be ERROR, WARNING
        [string]$LogFile = "C:\ForensicsTools\installation.log" # Log file path
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Type] $Message"
    Write-Output $logEntry # Write to console
    Add-Content -Path $LogFile -Value $logEntry # Write to log file
}

# Start of the script
Log-Message "Script execution started."

# Ensure the script is running with administrative privileges
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Log-Message "You do not have Administrator rights to run this script! Please re-run as an Administrator." -Type "ERROR"
    exit
}

# Set Execution Policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Define download URLs and installation paths
$autopsyUrl = "https://github.com/sleuthkit/autopsy/releases/download/autopsy-4.19.1/autopsy-4.19.1-64bit.msi"
$ftkImagerUrl = "https://ad-zip.s3.amazonaws.com/FTKImager.4.5.0.3.zip"
$wiresharkUrl = "https://2.na.dl.wireshark.org/win64/Wireshark-4.2.2-x64.exe"
$volatilityUrl = "https://downloads.volatilityfoundation.org/releases/2.6/volatility_2.6_win64_standalone.zip"
$sysinternalsSuiteUrl = "https://download.sysinternals.com/files/SysinternalsSuite.zip"

$installPath = "C:\ForensicsTools"
$sysinternalsPath = "$installPath\SysinternalsSuite"

# Create installation directory
New-Item -ItemType Directory -Force -Path $installPath

Try {
    # Download and Install Autopsy
    $autopsyPath = "$installPath\autopsy-4.19.1-64bit.msi"
    Invoke-WebRequest -Uri $autopsyUrl -OutFile $autopsyPath
    Start-Process msiexec.exe -Wait -ArgumentList "/i $autopsyPath /qn /norestart"
    Log-Message "Autopsy installed successfully."
} Catch {
    Log-Message "Failed to install Autopsy. Error: $_" -Type "ERROR"
}

<# Try {
    # Download and Unzip FTK Imager
    $ftkImagerZipPath = "$installPath\FTKImager.zip"
    Invoke-WebRequest -Uri $ftkImagerUrl -OutFile $ftkImagerZipPath
    Expand-Archive -LiteralPath $ftkImagerZipPath -DestinationPath "$installPath\FTKImager" -Force
    Log-Message "FTK Imager installed successfully."
} Catch {
    Log-Message "Failed to install FTK Imager. Error: $_" -Type "ERROR"
} #>

Try {
    # Download and Install Wireshark
    $wiresharkInstallerPath = "$installPath\Wireshark-win64-3.4.2.exe"
    Invoke-WebRequest -Uri $wiresharkUrl -OutFile $wiresharkInstallerPath
    Start-Process $wiresharkInstallerPath -Wait -ArgumentList "/S /quiet"
    Log-Message "Wireshark installed successfully."
} Catch {
    Log-Message "Failed to install Wireshark. Error: $_" -Type "ERROR"
}

<# Try {
    # Download and Unzip Volatility
    $volatilityZipPath = "$installPath\volatility_2.6_win64_standalone.zip"
    Invoke-WebRequest -Uri $volatilityUrl -OutFile $volatilityZipPath
    Expand-Archive -LiteralPath $volatilityZipPath -DestinationPath "$installPath\Volatility" -Force
    Log-Message "Volatility installed successfully."
} Catch {
    Log-Message "Failed to install Volatility. Error: $_" -Type "ERROR"
} #>

Try {
    # Download and Unzip Sysinternals Suite (includes Process Monitor)
    Invoke-WebRequest -Uri $sysinternalsSuiteUrl -OutFile "$sysinternalsPath.zip"
    Expand-Archive -LiteralPath "$sysinternalsPath.zip" -DestinationPath $sysinternalsPath -Force
    Log-Message "Sysinternals Suite installed successfully."
} Catch {
    Log-Message "Failed to install Sysinternals Suite. Error: $_" -Type "ERROR"
}

Log-Message "Installation of forensic tools complete."
