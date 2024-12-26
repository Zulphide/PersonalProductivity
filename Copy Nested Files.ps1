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

$source = Get-Folder -description "Select source folder"
$dest = Get-Folder -description "Select destination folder"

if ($source -and $dest) {
    $files = Get-ChildItem -Path $source -Recurse -File | Where-Object {
        $_.Extension -notin '.db', '.thumb', '.sys'
    }
    $fileCount = $files.Count
    $counter = 0

    foreach ($file in $files) {
        $folderName = $file.Directory.Name
        $newName = "$folderName - $($file.Name)"
        Copy-Item -Path $file.FullName -Destination (Join-Path -Path $dest -ChildPath $newName)
        $counter++
        Write-Progress -Activity "Copying files" -Status "$counter out of $fileCount" -PercentComplete (($counter / $fileCount) * 100)
    }

    Write-Host "$fileCount files have been copied."

    # Open a new File Explorer window for the source folder
    Start-Process explorer.exe -ArgumentList $source
} else {
    Write-Host "Folder selection was cancelled."
}

Read-Host -Prompt "Press Enter to exit"