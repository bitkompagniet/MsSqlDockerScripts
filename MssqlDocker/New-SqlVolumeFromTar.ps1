. $PSScriptRoot\Utils.ps1

function New-SqlVolumeFromTar {
    <#
        .SYNOPSIS
            Create a SQL data volume from a TAR file created with Copy-SqlVolumeToTar

        .EXAMPLE
            New-MssqlVolumeFromTar C:\MyPath\backup.tar
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]
        $TarFile,

        [Parameter(Position=1,Mandatory=$true)]
        [string]
        $Volume
    )

    if (![System.IO.File]::Exists($TarFile)) {
        throw "No such file: $TarFile"
    }

    if (-Not (HasRequirement docker)) {
        throw "docker not found in path."
    }

    if (VolumeExists $Volume) {
        throw "The volume '$Volume' already exists. This will only restore into a new volume."
    }

    $TarItem = (Get-Item $TarFile)
    $BaseName = $TarItem.Name
    $ContainerName = [guid]::NewGuid().ToString()

    docker run -itd --name $ContainerName --volume ${Volume}:/destination ubuntu >$null
    docker exec -it $ContainerName mkdir /source
    docker cp $TarFile ${ContainerName}:/source
    docker exec -it $ContainerName tar -xvf /source/$BaseName -C /destination
    docker rm -f $ContainerName >$null
}