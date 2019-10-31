function Copy-SqlVolumeToTar {
    <#
        .SYNOPSIS
            Dump an SQL container volume to a tar file.

        .EXAMPLE
            Copy-SqlVolumeToTar myvolume C:\MyPath\backup.tar
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Volume,

        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $Destination
    )

    $Exists = ([io.directory]::Exists($Destination) -or [io.file]::Exists($Destination))

    if ($Exists) {
        throw "The path already exists: $Destination"
    }

    $BaseName = [io.path]::GetFileName($Destination)
    $DirectoryOfDestination = [io.path]::GetDirectoryName($Destination)

    if (-not [io.directory]::Exists($DirectoryOfDestination)) {
        throw "The specified path does not exist: $DirectoryOfDestination"
    }

    docker stop mssql *>$null

    docker run -it --name volumetardump --volume ${Volume}:/source ubuntu tar -cvf /tmp/$BaseName -C /source .
    docker cp volumetardump:/tmp/$BaseName $DirectoryOfDestination 
    docker stop volumetardump >$null
    docker rm volumetardump >$null

    return [pscustomobject][ordered]@{ File = $Destination }
}