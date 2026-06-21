@echo off
setlocal

cd /d "%~dp0"

set "GEMMA4_MODEL=%CD%\models\gemma-4-E4B_q4_0-it.gguf"
set "GEMMA4_PORT=18082"
set "GEMMA4_ALIAS=gemma4-fast"
set "GEMMA4_LOG=%CD%\gemma4-fast-codex-server.log"
set "GEMMA4_MAX_OUTPUT_TOKENS=2048"

call "%CD%\start-gemma4-codex-server.cmd"
exit /b %ERRORLEVEL%
