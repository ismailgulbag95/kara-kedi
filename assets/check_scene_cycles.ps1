$scenes = Get-ChildItem -Path "d:\benim antigravitiler\kara kedi\scenes" -Recurse -Filter *.tscn

$graph = @{}

foreach ($s in $scenes) {
    $content = Get-Content $s.FullName -Raw
    $relPath = "res://" + ($s.FullName.Replace("d:\benim antigravitiler\kara kedi\", "").Replace("\", "/"))
    
    $deps = @()
    $matches = [regex]::Matches($content, '\[ext_resource[^\]]*type="PackedScene"[^\]]*path="([^"]+)"')
    foreach ($m in $matches) {
        $deps += $m.Groups[1].Value
    }
    $graph[$relPath] = $deps
}

Write-Output "=== DEPENDENCY GRAPH ==="
foreach ($k in $graph.Keys) {
    if ($graph[$k].Count -gt 0) {
        Write-Output "$k -> $($graph[$k] -join ', ')"
    }
}

# Check for Cycles
Write-Output "`n=== CHECKING FOR CYCLES ==="
function Check-Cycle($node, $visited, $stack) {
    $visited[$node] = $true
    $stack[$node] = $true

    if ($graph.ContainsKey($node)) {
        foreach ($neighbor in $graph[$node]) {
            if (-not $visited.ContainsKey($neighbor) -or -not $visited[$neighbor]) {
                if (Check-Cycle $neighbor $visited $stack) {
                    Write-Output "CYCLE DETECTED: $node -> $neighbor"
                    return $true
                }
            } elseif ($stack.ContainsKey($neighbor) -and $stack[$neighbor]) {
                Write-Output "CYCLE DETECTED (Direct/Indirect loop): $node -> $neighbor"
                return $true
            }
        }
    }

    $stack[$node] = $false
    return $false
}

$visited = @{}
$stack = @{}
foreach ($node in $graph.Keys) {
    if (-not $visited.ContainsKey($node) -or -not $visited[$node]) {
        Check-Cycle $node $visited $stack | Out-Null
    }
}
