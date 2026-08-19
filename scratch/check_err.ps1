$logs = Get-ChildItem "C:\Users\ismai\AppData\Roaming\Godot\app_userdata\*\logs\*.log" | Sort-Object LastWriteTime -Descending
foreach ($l in $logs | Select-Object -First 3) {
    Write-Output "=== LOG FILE: $($l.FullName) ($($l.LastWriteTime)) ==="
    Get-Content $l.FullName -Tail 50
}
