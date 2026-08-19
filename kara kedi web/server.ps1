$port = 8000
$path = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Output "HTTP_SERVER_RUNNING on http://localhost:$port/"

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $req = $context.Request
        $res = $context.Response
        
        $localPath = $req.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrEmpty($localPath)) { $localPath = "index.html" }
        $fullPath = Join-Path $path $localPath
        
        if (Test-Path $fullPath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($fullPath)
            $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
            if ($ext -eq ".html") { $res.ContentType = "text/html; charset=utf-8" }
            elseif ($ext -eq ".js") { $res.ContentType = "application/javascript; charset=utf-8" }
            elseif ($ext -eq ".png") { $res.ContentType = "image/png" }
            elseif ($ext -eq ".css") { $res.ContentType = "text/css; charset=utf-8" }
            elseif ($ext -eq ".svg") { $res.ContentType = "image/svg+xml" }
            
            $res.ContentLength64 = $bytes.Length
            if ($req.HttpMethod -ne "HEAD") {
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
            }
        } else {
            $res.StatusCode = 404
        }
        $res.Close()
    } catch {
        # Continue loop on client disconnect
    }
}
