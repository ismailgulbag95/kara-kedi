$logPath = "C:\Users\ismai\AppData\Roaming\Godot\app_userdata\Kara Kedi- Fare İstilas\logs\godot.log"
if (!(Test-Path $logPath)) {
    $files = Get-ChildItem "C:\Users\ismai\AppData\Roaming\Godot\app_userdata" -Recurse -Filter "godot.log"
    if ($files) { $logPath = $files[0].FullName }
}
if (Test-Path $logPath) {
    Get-Content $logPath -Tail 100
} else {
    Write-Output "LOG_NOT_FOUND"
}
