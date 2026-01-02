$ErrorActionPreference = 'Stop'
$dest = "assets/fonts"
if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

# Download the variable Inter font (file name contains brackets, so use the URL-encoded path)
$base = "https://raw.githubusercontent.com/google/fonts/main/ofl/inter/"
$varEncoded = "Inter%5Bopsz%2Cwght%5D.ttf"
$varUrl = $base + $varEncoded
$varOut = Join-Path $dest "Inter-variable.ttf"
Write-Output "Downloading variable Inter font from $varUrl"
Invoke-WebRequest -Uri $varUrl -OutFile $varOut -UseBasicParsing

# Copy the variable font to the filenames referenced in pubspec.yaml so bundling succeeds
$targets = @(
  "Inter-Regular.ttf",
  "Inter-Medium.ttf",
  "Inter-SemiBold.ttf",
  "Inter-Bold.ttf"
)
foreach ($t in $targets) {
  $destPath = Join-Path $dest $t
  Copy-Item -Path $varOut -Destination $destPath -Force
  Write-Output "Wrote $destPath"
}

Write-Output "Fonts prepared in $dest"