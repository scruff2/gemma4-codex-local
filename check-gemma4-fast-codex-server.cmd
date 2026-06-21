@echo off
setlocal

set "GEMMA4_PORT=18082"
set "GEMMA4_ALIAS=gemma4-fast"

call "%~dp0check-gemma4-codex-server.cmd"
exit /b %ERRORLEVEL%
