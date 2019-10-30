docker stop sqlexpress

$dd = (Get-Date -Format "yyyy-MM-dd")
$filename = "${dd}_sqlfys_volume.tar"

docker run --rm --volume sqlfys:/source --volume ${PWD}:/destination ubuntu tar -cvf /destination/$filename -C /source .

Write-Output "${PWD}\$filename"