$tscnFiles = Get-ChildItem "d:\benim antigravitiler\kara kedi\scenes" -Recurse -Filter "*.tscn"
foreach ($file in $tscnFiles) {
    $content = Get-Content $file.FullName -Raw
    # Remove all uid="..." attributes from [gd_scene ...] and [ext_resource ...]
    $newContent = $content -replace ' uid="uid://[^"]*"', ''
    Set-Content -Path $file.FullName -Value $newContent -NoNewline
    Write-Output "CLEANED_UIDS: $($file.Name)"
}
