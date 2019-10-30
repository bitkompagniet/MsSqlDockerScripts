[CmdletBinding()]
param (
    [Parameter(Position=0,Mandatory=$true)]
    [string]
    $TarFile
)

if (![System.IO.File]::Exists($TarFile)) {
    Write-Output "No such file: $TarFile"
    exit 1
}

$PathOfFile = (Get-Item $TarFile).Directory.FullName
$BaseName = [System.IO.Path]::GetFileName($TarFile)

Write-Output $PathOfFile
Write-Output $BaseName

#docker run --rm --volume sqlfys:/source --volume ${PWD}/Dumps:/destination ubuntu tar -cvf /destination/$filename -C /source .
docker stop sqlexpress
docker run --rm --volume ${PathOfFile}:/source --volume sqlfys:/destination ubuntu tar -xvf /source/$BaseName -C /destination
#docker run --rm --volume sqlfys:/source --volume ${PWD}/Dumps:/destination ubuntu ls -la /source