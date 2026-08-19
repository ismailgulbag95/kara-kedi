$tempDir = Join-Path $env:TEMP "gh-pages-deploy"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Copy-Item "build\web\*" $tempDir -Recurse -Force
Push-Location $tempDir
git init
git config user.name "BalabanKhan"
git config user.email "BalabanKhan@users.noreply.github.com"
git checkout -b gh-pages
git add -A
git commit -m "Deploy Godot Web build to GitHub Pages"
git remote add origin https://github.com/ismailgulbag95/kara-kedi.git
git push -f origin gh-pages
Pop-Location
Remove-Item $tempDir -Recurse -Force
Write-Host "Pushed to gh-pages branch successfully!"
