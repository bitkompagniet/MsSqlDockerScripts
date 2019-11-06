. $PSScriptRoot\Utils.ps1

function New-SqlDockerContainer {
    <#
        .SYNOPSIS
            Start a new MSSQL Docker Container

        .EXAMPLE
            New-SqlDockerContainer -Volume mydbvol -Port 1433
    #>
    [CmdletBinding()]
    param (

        # The docker volume to mount.
        [Parameter()]
        [string]
        $Volume,

        # The SA password set on the MSSQL Instance. Will default to '!paSSw0rd'.
        [Parameter()]
        [string]
        $SqlPassword = "!paSSw0rd",

        # Optionally point at a BAK file that will be copied into the container.
        [Parameter()]
        [string]
        $CopyBakFile,

        # The container name, defaults to 'mssql'.
        [Parameter()]
        [string]
        $DockerContainerName = "mssql",

        # Set the host port that the MSSQL server can be reached on (localhost:port).
        [Parameter()]
        [int]
        $Port = 1433,

        # The MSSQL PID / mode - defaults to 'Developer'.
        [Parameter()]
        [ValidateSet('Developer', 'Express', 'Standard', 'Enterprise', 'EnterpriseCore')]
        [string]
        $Pid = 'Developer'
    )

    $Result = [ordered]@{
        Container = $DockerContainerName
        Port = $Port
        Pid = $Pid
    }

    if (-Not (HasRequirement docker)) {
        throw "docker not found in path."
    }

    $VolumeDefined = (!([string]::IsNullOrWhiteSpace($Volume)))
    $VolumeString = ""

    if ($VolumeDefined) {

        $PasswordExplicitlySet = $PSBoundParameters.ContainsKey('SqlPassword')
        $VolumeExists = (VolumeExists $Volume)

        if ($PasswordExplicitlySet -and $VolumeExists) {
            throw "Password can only be set on a new volume. The volume '$Volume' already exists."
        } 
        
        if (-not $VolumeExists) {
            $Result.Add('SqlPassword', $SqlPassword)
        }

        $VolumeString = "-v`"${Volume}:/var/opt/mssql`""
        $Result.Add('Volume', $Volume)
    } else {
        $Result.Add('SqlPassword', $SqlPassword)
    }

    docker rm -f $DockerContainerName *>$null
    docker run --name $DockerContainerName -e ACCEPT_EULA='Y' -e SA_PASSWORD="$SqlPassword" -e MSSQL_PID="$Pid" -p ${Port}:1433 $VolumeString -d mcr.microsoft.com/mssql/server:2017-latest-ubuntu >$null

    if (!$?) {
        throw "Failure to create docker container."
    }

    $Result.Add('Connection string', "Server=localhost;Database=master;User Id=sa;Password=$SqlPassword;")

    if ([System.IO.File]::Exists($CopyBakFile)) {
        $BaseName = [System.IO.Path]::GetFileName($CopyBakFile)
        docker cp $CopyBakFile ${DockerContainerName}:/tmp/
        $Result.Add('BakFilePath', "/tmp/${BaseName}")
    }

    return [pscustomobject]$Result
}