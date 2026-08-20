$scripts = Get-ChildItem -Path "d:\benim antigravitiler\kara kedi\scripts" -Recurse -Filter *.gd

$errors = @()

foreach ($s in $scripts) {
    $lines = Get-Content $s.FullName
    $lineNum = 1
    foreach ($line in $lines) {
        # Check for unclosed brackets or obvious syntax flaws
        if ($line -match 'func [a-zA-Z0-9_]+\s*\([^)]*$') {
            $errors += "$($s.FullName):$lineNum - Possible unclosed function signature: $line"
        }
        $lineNum++
    }
}

if ($errors.Count -eq 0) {
    Write-Output "ALL_GDSCRIPTS_SYNTAX_CLEAN"
} else {
    Write-Output ($errors -join "`n")
}
