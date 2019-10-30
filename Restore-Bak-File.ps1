[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] 
    $BakFile,

    [Parameter(Mandatory=$true, Position=1)]
    [string] 
    $VolumeName
)

$ContainerName = "sqltemporary"
$Password = "7cFgdr!5B7J(#X&"

if (![System.IO.File]::Exists($BakFile)) {
    Write-Output "File not found: $BakFile"
    exit 1
}

$PsContainersUsingVolume = ((docker ps -a --filter volume=$VolumeName).Count - 1)

if ($PsContainersUsingVolume -gt 0) {
    Write-Output "There are containers using $VolumeName, so we cannot continue."
    exit 1
}

docker run --name $ContainerName -e ACCEPT_EULA='Y' -e SA_PASSWORD="$Password" -e MSSQL_PID='Express' -p 1433:1433 -v ${VolumeName}:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2017-latest-ubuntu

if (!$?) {
    Write-Output "Something went wrong when trying to start the container."
    exit 1
}

docker cp $BakFile ${ContainerName}:/tmp/

$BaseName = (Get-Item $BakFile).Name
$InContainerPath = "/tmp/$BaseName"

Write-Output $InContainerPath

$FileListOnly = (docker exec -it ${ContainerName} /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$Password" -Q "RESTORE FILELISTONLY FROM DISK = '$InContainerPath'")

$Cutout = $FileListOnly[2..($FileListOnly.Length - 3)]

$Items = @()
$SqlMove = @()

foreach ($element in $Cutout) {

    if ($element.Length -gt 0) {
        $logicalName = $element.Substring(0, 129).Trim()
        $physicalName = $element.Substring(129, 261).Trim()
        $fname = [System.IO.Path]::GetFileName($physicalName)

        $hash = @{ Logical = $logicalName; Physical = $physicalName; Basename = $fname }
        $SqlMove += "MOVE '$logicalName' TO '/var/opt/mssql/data/${fname}'"

        $Items += $hash
    }
}

$DbName = $Items[0].Logical

Write-Output $DbName

$joined = [System.string]::Join(", ", $SqlMove)

$FullSql = "RESTORE DATABASE $DbName FROM DISK = '$InContainerPath' WITH KEEP_REPLICATION, " + $joined

Write-Output $FullSql

docker exec -it ${ContainerName} /opt/mssql-tools/bin/sqlcmd `
  -S localhost -U SA -P "$Password" `
  -Q "$FullSql"

docker rm --force ${ContainerName}