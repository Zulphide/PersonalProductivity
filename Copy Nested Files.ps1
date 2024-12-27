# Define get-folder function
Function Get-Folder($description, $initialDirectory="") {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $description
    $foldername.RootFolder = [System.Environment+SpecialFolder]::MyComputer
    $foldername.SelectedPath = $initialDirectory

    if ($foldername.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $foldername.SelectedPath
    }
    return $null
}

$source = Get-Folder -description "SELECT SOURCE FOLDER"

# Check for subfolders
$subfolders = Get-ChildItem -Path $source -Directory
if ($subfolders.Count -eq 0) {
    Write-Host "There are no sub-folders in the source, please proceed with files directly."
    Read-Host -Prompt "Press Enter to exit"
    exit
}

$dest = Get-Folder -description "SELECT DESTINATION FOLDER"

# Set up file count and for each loop, write progress during copy.
if ($source -and $dest) {
    $files = Get-ChildItem -Path $source -Recurse -File | Where-Object {
        $_.Extension -notin '.db', '.thumb', '.sys'
    }
    $fileCount = $files.Count
    $counter = 0

    foreach ($file in $files) {
        try {
            $folderName = $file.Directory.Name
            $newName = "$folderName - $($file.Name)"
            Copy-Item -Path $file.FullName -Destination (Join-Path -Path $dest -ChildPath $newName)
            $counter++
            Write-Progress -Activity "Copying files" -Status "$counter out of $fileCount" -PercentComplete (($counter / $fileCount) * 100)
        } catch {
            Write-Warning "Could not access file: $($file.FullName)"
        }
    }

    Write-Host "$counter out of $fileCount files have been copied."

    # Open a new File Explorer window for the destination folder
    Start-Process explorer.exe -ArgumentList $dest
} else {
    Write-Host "Folder selection was cancelled."
}

Read-Host -Prompt "Script finished. Press Enter to exit"
