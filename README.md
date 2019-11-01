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

Clone this repository, and from the root of the project folder, run:

```ps
.\Install.ps1
```

If you wish to update, pull the changes and run:

```ps
.\Install.ps1 -Overwrite
```
