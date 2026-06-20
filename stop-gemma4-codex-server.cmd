@echo off
setlocal

if "%GEMMA4_PORT%"=="" set "GEMMA4_PORT=18080"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$port = '%GEMMA4_PORT%';" ^
  "$pattern = '127\.0\.0\.1:' + $port + '|0\.0\.0\.0:' + $port + '|\[::\]:' + $port;" ^
  "$lines = netstat -ano | Select-String -Pattern $pattern;" ^
  "$pids = @();" ^
  "foreach ($line in $lines) { $parts = ($line.ToString() -split '\s+') | Where-Object { $_ }; if ($parts.Count -ge 5 -and $parts[3] -eq 'LISTENING') { $pids += [int]$parts[4] } }" ^
  "$pids = $pids | Select-Object -Unique;" ^
  "if (-not $pids) { Write-Host ('No Gemma 4 Codex server is listening on port ' + $port + '.'); exit 0 }" ^
  "foreach ($processId in $pids) { Stop-Process -Id $processId -Force -ErrorAction Stop; Write-Host ('Stopped process ' + $processId + ' on port ' + $port + '.') }"

exit /b %ERRORLEVEL%
