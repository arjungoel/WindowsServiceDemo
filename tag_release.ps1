# Create a new release.txt file
New-Item -ItemType File -Path .\release.txt

# Fetch the latest tags from the remote repository
git fetch --tags

# Find the latest version tag
$lastTagObj = git tag --sort=-creatordate | Where-Object { $_ -match 'v1\.\d+\.\d+-[A-Za-z0-9]+' } | Sort-Object | Select-Object -Last 1
Write-Host "lastTagObj: $lastTagObj"

# Check if the tag already exists
if ($lastTagObj -eq $null) {
    Write-Host "No previous tags found. Starting with v1.0.0-master."
    $lastTag = "v1.0.0-master"
} else {
    $lastTag = "$lastTagObj"
    Write-Host "lastTag: $lastTag"
}

# Extract version number from the last tag
$lengthOfTag = $lastTag.Length
Write-Host "lengthOfTag: $lengthOfTag"
$sIndex = $lastTag.IndexOf("v") + 1
$eIndex = $lastTag.IndexOf("-") - 1
Write-Host "sIndex: $sIndex, eIndex: $eIndex"
$tagVersion = $lastTag.SubString($sIndex, $eIndex - $sIndex + 1)
Write-Host "tagVersion: $tagVersion" 

# Generate the numeric version without dots
$numericTagVersion = $tagVersion -split '\.' -join ''
Write-Host "numericTagVersion: $numericTagVersion" 

# Increment the numeric version
$nextNumericTagVersion = [int]$numericTagVersion + 1
Write-Host "nextNumericTagVersion: $nextNumericTagVersion"

# Format the final version with dots
$finalTagVersion = $nextNumericTagVersion -replace '(\d)(?=(\d{1,2})+$)', '$1.'
Write-Host "finalTagVersion: $finalTagVersion"

# Generate the final tag name
$finalTagVersionName = "v" + $finalTagVersion + "-master"
Write-Host "finalTagVersionName: $finalTagVersionName"

# Check if the tag already exists in the remote repository
if (git ls-remote --tags origin | Out-String -contains $finalTagVersionName) {
    Write-Host "Tag $finalTagVersionName already exists in the remote repository. Aborting."
} else {
    # Continue with tag creation and pushing
    git tag -a $finalTagVersionName -m "New release version"
    git push origin $finalTagVersionName
    Write-Host "$finalTagVersionName is created successfully"
}
