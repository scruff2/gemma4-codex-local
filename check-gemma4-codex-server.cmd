@echo off
setlocal

if "%GEMMA4_HOST%"=="" set "GEMMA4_HOST=127.0.0.1"
if "%GEMMA4_PORT%"=="" set "GEMMA4_PORT=18080"
if "%GEMMA4_ALIAS%"=="" set "GEMMA4_ALIAS=gemma4-codex"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$base = 'http://%GEMMA4_HOST%:%GEMMA4_PORT%/v1';" ^
  "$model = '%GEMMA4_ALIAS%';" ^
  "$models = Invoke-RestMethod -Uri ($base + '/models') -TimeoutSec 5;" ^
  "Write-Host 'Models endpoint is reachable.';" ^
  "$ids = @($models.data | ForEach-Object { $_.id });" ^
  "if ($ids -notcontains $model) { throw ($model + ' was not listed by /v1/models.') }" ^
  "Write-Host ($model + ' is listed.');" ^
  "$body = @{ model = $model; input = 'Reply with only: ready'; max_output_tokens = 8; temperature = 0 } | ConvertTo-Json -Depth 8;" ^
  "$response = Invoke-RestMethod -Uri ($base + '/responses') -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 60;" ^
  "$text = (($response.output | Select-Object -First 1).content | Select-Object -First 1).text;" ^
  "Write-Host ('Responses endpoint returned: ' + $text);"

exit /b %ERRORLEVEL%
