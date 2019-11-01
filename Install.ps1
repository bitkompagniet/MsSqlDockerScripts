[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Overwrite = $false
)

$SourcePath = [io.path]::Combine($PSScriptRoot, "MssqlDocker")
$BaseModulePath = ($env:PSModulePath -split "[:;]")[0]
$InstallPath = [io.path]::Combine($BaseModulePath, "MssqlDocker")
$Exists = (([io.file]::Exists($InstallPath)) -or ([io.directory]::Exists($InstallPath)))

if ($Exists) {
    if ($Overwrite) {
        Remove-Item $InstallPath -Recurse -Force
    } else {
        Write-Output "Already exists, and not set to overwrite. Quitting."
        exit 1
    }
}

$Result = @{
    SourcePath = $SourcePath
    ModulePath = $BaseModulePath
}

Write-Output $Result
Copy-Item -Path $SourcePath -Recurse -Destination $BaseModulePath