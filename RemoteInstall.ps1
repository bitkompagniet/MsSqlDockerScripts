$destination = [io.path]::Combine($env:TEMP, "MsSqlDockerScripts")
Remove-Item $destination -Recurse -Force *>$null

git clone https://github.com/bitkompagniet/MsSqlDockerScripts.git $destination
Push-Location $destination

.\Install.ps1 -Overwrite

Pop-Location
Remove-Item $destination -Recurse -Force *>$null