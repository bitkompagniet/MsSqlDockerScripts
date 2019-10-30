[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [string]
    $BakFile,

    [Parameter()]
    [string] 
    $DbName = "NAV_Repl",

    [Parameter()]
    [string]
    $DbPassword = "7cFgdr!5B7J(#X&"
)

docker rm -f sqlexpress *>$null
docker run --name sqlexpress -e ACCEPT_EULA='Y' -e SA_PASSWORD="$DbPassword" -e MSSQL_PID='Express' -p 1433:1433 -v sqlfys:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2017-latest-ubuntu

if ($?) {
    Write-Output "Server=localhost;Database=$DbName;User Id=sa;Password=$DbPassword;MultipleActiveResultSets=True;"
} else {
    Write-Output "Failure to create docker container."
    exit 1
}

if ([System.IO.File]::Exists($BakFile)) {
    $BaseName = [System.IO.Path]::GetFileName($BakFile)
    docker cp $BakFile sqlexpress:/tmp/
    Write-Output "/tmp/${BaseName}"
}