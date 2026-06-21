@echo off
setlocal

set "GEMMA4_PORT=18082"

call "%~dp0stop-gemma4-codex-server.cmd"
exit /b %ERRORLEVEL%
