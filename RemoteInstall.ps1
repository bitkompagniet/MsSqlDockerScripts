$destination = [io.path]::Combine($env:TEMP, "MsSqlDockerScripts")
Remove-Item $destination -Recurse -Force

git clone https://github.com/bitkompagniet/MsSqlDockerScripts.git $destination
cd $destination

.\Install.ps1 -Overwrite