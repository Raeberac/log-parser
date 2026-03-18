$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "DarkGray"
Clear-Host

$ConfigPath = "$PSScriptRoot\parser_config.json"
$DefaultKeywords = @("warn", "critical", "fatal", "fail", "error")

if (-not (Test-Path $ConfigPath)) {
    $Config = @{ Keywords = $DefaultKeywords }
    $Config | ConvertTo-Json | Out-File $ConfigPath
}


function Invoke-Parse {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        Write-Host " [!] ERROR: File not found at $FilePath" -ForegroundColor Red
        return
    }

    $FileName = Split-Path $FilePath -Leaf
    $OutputDir = Split-Path $FilePath -Parent
    if (-not $OutputDir) { $OutputDir = $PSScriptRoot }
    $OutputPath = Join-Path $OutputDir "parsed-$FileName"
    
    $CurrentConfig = Get-Content $ConfigPath | ConvertFrom-Json
    $CurrentKeywords = $CurrentConfig.Keywords
    $Pattern = ($CurrentKeywords | ForEach-Object { [regex]::Escape($_) }) -join '|'

    Write-Host " [*] PARSING: $FileName" -ForegroundColor DarkGray
    Write-Host " [*] SEARCHING FOR: $($CurrentKeywords -join ', ')" -ForegroundColor DarkGray

    try {
        $Results = Get-Content $FilePath | Where-Object { $_ -match $Pattern }
        
        if ($Results) {
            $Results | Out-File -FilePath $OutputPath
            Write-Host " [+] SUCCESS: Matches exported to $OutputPath" -ForegroundColor Green
        } else {
            Write-Host " [!] NOTICE: No matching keywords found." -ForegroundColor Red
        }
    } catch {
        Write-Host " [!] CRITICAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-KeyEdit {
    param([string]$NewKeyword)

    if ([string]::IsNullOrWhiteSpace($NewKeyword)) {
        Write-Host " [!] ERROR: Keyword cannot be empty." -ForegroundColor Red
        return
    }

    $CurrentConfig = Get-Content $ConfigPath | ConvertFrom-Json
    
    if ($CurrentConfig.Keywords -contains $NewKeyword) {
        Write-Host " [!] ERROR: Keyword '$NewKeyword' already exists." -ForegroundColor Red
    } else {
        $CurrentConfig.Keywords += $NewKeyword
        $CurrentConfig | ConvertTo-Json | Out-File $ConfigPath
        Write-Host " [+] SUCCESS: Added '$NewKeyword' to config." -ForegroundColor Green
    }
}

Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray
Write-Host " LOG PARSER v1" -ForegroundColor Green
Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray
Write-Host " Available Commands:" -ForegroundColor DarkGray
Write-Host "  parse 'path'   - Scans log file for keywords" -ForegroundColor Green
Write-Host "  keyedit 'word' - Adds a new persistent keyword" -ForegroundColor Green
Write-Host "  exit           - Closes the script" -ForegroundColor Red
Write-Host "--------------------------------------------------------" -ForegroundColor DarkGray

while ($true) {
    Write-Host " >> " -ForegroundColor DarkGray -NoNewline
    $Input = Read-Host
    
    if ($Input -eq "exit") { break }
    
    if ($Input -match "^parse\s+(.+)") {
        $Path = $matches[1].Trim("'").Trim('"')
        Invoke-Parse -FilePath $Path
    } 
    elseif ($Input -match "^keyedit\s+(.+)") {
        $Word = $matches[1].Trim("'").Trim('"')
        Invoke-KeyEdit -NewKeyword $Word
    }
    else {
        Write-Host " [!] Unknown Command. Use 'parse' or 'keyedit'." -ForegroundColor Red
    }
}
