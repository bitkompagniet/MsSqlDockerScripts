. $PSScriptRoot\Utils.ps1

function Remove-SqlDockerContainer {
    <#
        .SYNOPSIS
            Remove a MSSQL Docker Container

        .EXAMPLE
            Remove-SqlDockerContainer
    #>
    [CmdletBinding()]
    param (
        # The container name, defaults to 'mssql'.
        [Parameter()]
        [string]
        $DockerContainerName = "mssql"
    )

    if (-Not (HasRequirement docker)) {
        throw "docker not found in path."
    }

    docker stop $DockerContainerName >$null
    docker rm $DockerContainerName >$null
}