# MsSqlDockerScripts

Powershell scripts for building MSSQL Docker containers easily.

There are currently commands for:

- Spinning up a MSSQL docker container.
- Creating a docker volume from a BAK file.
- Backing up a docker volume to a tar file.
- Creating a docker volume from a tar file.

## Commands

Create a new SQL data volume from an existing BAK file.

```ps
New-SqlVolumeFromBak -BakFile C:\Backup.BAK -Volume myvolume
```

Now, start a MSSQL container with the new volume attached.

```ps
New-SqlDockerContainer -Volume myvolume
```

With no further args given, the SQL instance will start up in 'Developer' mode in a container named `mssql` on port 1433. This is all configurable.

You can now export the volume to a tar archive.

_Stop the container before you back up the volume, otherwise the result may be invalid._

```ps
Copy-SqlVolumeToTar -Volume myvolume -Destination C:\Backup.tar
```

This process can be reversed.

```ps
New-SqlVolumeFromTar -Volume myvolume2 -TarFile C:\Backup.tar
```


## Installation

To just immediately install this plugin without further ado, run:

```ps
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/bitkompagniet/MsSqlDockerScripts/master/RemoteInstall.ps1'))
```

If you didn't see any errors, the module is now placed in your default module folder. Open a new shell to make the changes take effect.

Clone this repository, and from the root of the project folder, run:

```ps
.\Install.ps1
```

If you wish to update, pull the changes and run:

```ps
.\Install.ps1 -Overwrite
```
