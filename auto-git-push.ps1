$repo = "E:\javacode\game-automation-repo"
$logDir = "E:\javacode\game-automation-logs"
$logFile = Join-Path $logDir ("auto-git-push-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log")

New-Item -ItemType Directory -Force -Path $logDir | Out-Null

Start-Transcript -Path $logFile -Append

try {
    Write-Host "Repo: $repo"
    Write-Host "Log: $logFile"

    Set-Location $repo

    git status
    if ($LASTEXITCODE -ne 0) { throw "git status failed" }

    git pull --rebase origin main
    if ($LASTEXITCODE -ne 0) { throw "git pull --rebase failed" }

    $changes = git status --porcelain

    if (-not $changes) {
        Write-Host "No changes to commit."
        exit 0
    }

    git add -- .
    if ($LASTEXITCODE -ne 0) { throw "git add failed" }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    git commit -m "Automated game update $timestamp"
    if ($LASTEXITCODE -ne 0) { throw "git commit failed" }

    git push
    if ($LASTEXITCODE -ne 0) { throw "git push failed" }

    git status
}
catch {
    Write-Error $_
    exit 1
}
finally {
    Stop-Transcript
}