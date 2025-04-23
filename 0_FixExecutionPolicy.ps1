# unblock_and_allow_scripts.ps1

# Define log path
$LogFile = "$env:USERPROFILE\\script_unlock_log.txt"
"[$(Get-Date)] Starting script unlock process..." | Out-File -Append $LogFile

# Request elevation if needed
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    "[$(Get-Date)] Not running as admin, re-launching..." | Out-File -Append $LogFile
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 1. Set execution policy for current user
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    "[$(Get-Date)] ExecutionPolicy set to RemoteSigned for CurrentUser." | Out-File -Append $LogFile
} catch {
    "[$(Get-Date)] Failed to set execution policy: $_" | Out-File -Append $LogFile
}

# 2. Set execution policy for local machine (fallback)
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    "[$(Get-Date)] ExecutionPolicy set to RemoteSigned for LocalMachine." | Out-File -Append $LogFile
} catch {
    "[$(Get-Date)] Failed to set LocalMachine policy (probably not admin): $_" | Out-File -Append $LogFile
}

# 3. Unblock all .ps1 files in known script folders
$TargetDirs = @(
    "$env:USERPROFILE\\Desktop\\LLM_PROJECTS\\pshell_scripts",
    "$env:USERPROFILE\\Desktop\\LLM_PROJECTS\\DLA\\DailyLoginAutomator"
)

foreach ($dir in $TargetDirs) {
    if (Test-Path $dir) {
        $ps1Files = Get-ChildItem -Path $dir -Recurse -Filter *.ps1 -ErrorAction SilentlyContinue
        foreach ($file in $ps1Files) {
            try {
                Unblock-File -Path $file.FullName
                "[$(Get-Date)] Unblocked: $($file.FullName)" | Out-File -Append $LogFile
            } catch {
                "[$(Get-Date)] Failed to unblock: $($file.FullName) — $_" | Out-File -Append $LogFile
            }
        }
    } else {
        "[$(Get-Date)] Target directory not found: $dir" | Out-File -Append $LogFile
    }
}

"[$(Get-Date)] Script unlock process completed." | Out-File -Append $LogFile
Write-Output "✅ Scripts unlocked, execution policy set. Check log at $LogFile"
