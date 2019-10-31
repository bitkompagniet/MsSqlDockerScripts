. $PSScriptRoot\Utils.ps1

function New-SqlVolumeFromBak {
    <#
        .SYNOPSIS
            Create a SQL data volume from a BAK file created in MSSQL tools.

        .EXAMPLE
            New-SqlVolumeFromBak -BakFile C:\MyPath\backup.bak -Volume myvolume
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] 
        $BakFile,
    
        [Parameter(Mandatory=$true, Position=1)]
        [string] 
        $Volume
    )
    
    $ContainerName = [guid]::NewGuid().ToString()
    $Password = "7cFgdr!5B7J(#X&"
    
    if (![System.IO.File]::Exists($BakFile)) {
        throw "File not found: $BakFile"
    }

    if (-Not (HasRequirement docker)) {
        throw "docker not found in path."
    }

    if (VolumeExists $Volume) {
        throw "The volume '$Volume' already exists. This will only restore into a new volume."
    }
    
    docker run --name $ContainerName -e ACCEPT_EULA='Y' -e SA_PASSWORD="$Password" -e MSSQL_PID='Developer' -p 1433:1433 -v ${Volume}:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2017-latest-ubuntu >$null
    
    if (!$?) {
        throw "Something went wrong when trying to start the container."
    }
    
    docker cp $BakFile ${ContainerName}:/tmp/
    
    $BaseName = (Get-Item $BakFile).Name
    $InContainerPath = "/tmp/$BaseName"
    
    $FileListOnly = (docker exec -it ${ContainerName} /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "$Password" -Q "RESTORE FILELISTONLY FROM DISK = '$InContainerPath'")
    
    $Cutout = $FileListOnly[2..($FileListOnly.Length - 3)]
    
    $Result = [ordered]@{}
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

    $Result.Add('MovedItems', $Items)
    
    $DbName = $Items[0].Logical
    
    $Result.Add('Database', $DbName)
    
    $joined = [System.string]::Join(", ", $SqlMove)
    
    $FullSql = "RESTORE DATABASE $DbName FROM DISK = '$InContainerPath' WITH KEEP_REPLICATION, " + $joined
    
    $Result.Add('SQL', $FullSql)
    
    docker exec -it ${ContainerName} /opt/mssql-tools/bin/sqlcmd `
      -S localhost -U SA -P "$Password" `
      -Q "$FullSql" `
      >$null
    
    docker rm --force ${ContainerName} >$null

    return $Result
}
