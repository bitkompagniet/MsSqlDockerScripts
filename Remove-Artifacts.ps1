param(
    [Parameter()]
    [switch] $Hard=$false
)


$RootDirectory = (Get-Item $PSScriptRoot).Parent.FullName
$desktop = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

Write-Output $desktop

$projects = @(
    "api",
    "login",
    "membership",
    "newsletter"
)

$removepaths = @()

$removepaths += [io.path]::Combine($RootDirectory, "Fysio.Frontend", "dist")

if ($Hard)
{
    $removepaths += [io.path]::Combine($RootDirectory, "Fysio.Frontend", "bower_components")
    $removepaths += [io.path]::Combine($RootDirectory, "Fysio.Frontend", "node_modules")
}

$contentpaths = $projects | % { [io.path]::Combine($RootDirectory, "Fysio.Web." + $_, "Content") }

$removepaths += $contentpaths

$desktoppaths = $projects | % { [io.path]::Combine($desktop, "fysio." + $_) }

$removepaths += $desktoppaths

foreach ($r in $removepaths)
{
    if (test-path $r)
    {
        Write-Output "Removing item $r"
        Remove-Item -force -Recurse $r
    }
    else
    {
        Write-Output "$r did not exist."
    }
}