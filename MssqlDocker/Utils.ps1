function HasRequirement {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $CommandName
    )

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'

    try {
        Get-Command $CommandName
        return $true
    } catch {
        return $false
    } finally {
        $ErrorActionPreference = $oldPreference
    }
}

function VolumeExists {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Volume
    )

    docker inspect $Volume *>$null
    return $?
}