# add variables
$siteUrl = "https://YourTenantName.sharepoint.com/sites/YourSiteName"
$libraryName = "Documents"  # Replace with your DL name

# Connect to SharePoint Online
Connect-PnPOnline -Url $siteUrl -UseWebLogin


# Get all items from the document library
$items = Get-PnPListItem -List $libraryName -PageSize 500 -Fields FileLeafRef, FileDirRef

# Create array to store possible duplicates
$potentialDuplicates = @()

# Check for duplicate patterns in file/folder names
foreach ($item in $items) {
    $fileName = $item["FileLeafRef"]
    $filePath = $item["FileDirRef"]

    # Check for computer name pattern in the file/folder name (e.g., "-PCName" or "-Laptop")  Hopefully works?
    if ($fileName -match "-\w+$") {
        $potentialDuplicates += [PSCustomObject]@{
            Name     = $fileName
            Path     = $filePath
            FullPath = "$filePath/$fileName"
        }
    }
}

# Output potential duplicates
if ($potentialDuplicates.Count -gt 0) {
    Write-Host "Potential duplicates found:" -ForegroundColor Green
    $potentialDuplicates | Format-Table -AutoSize
} else {
    Write-Host "No potential duplicates found." -ForegroundColor Yellow
}

# Optionally export to a CSV
$potentialDuplicates | Export-Csv -Path "PotentialDuplicates.csv" -NoTypeInformation