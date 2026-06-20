@echo off
setlocal

cd /d "%~dp0"

if not defined GEMMA4_LLAMA_SERVER if exist "%CD%\llama-cpp\llama-server.exe" set "GEMMA4_LLAMA_SERVER=%CD%\llama-cpp\llama-server.exe"
if not defined GEMMA4_LLAMA_SERVER if exist "%USERPROFILE%\Documents\Voice-Enabled\tools\llama-cpp\llama-server.exe" set "GEMMA4_LLAMA_SERVER=%USERPROFILE%\Documents\Voice-Enabled\tools\llama-cpp\llama-server.exe"
if not defined GEMMA4_LLAMA_SERVER set "GEMMA4_LLAMA_SERVER=%CD%\llama-cpp\llama-server.exe"

if not defined GEMMA4_MODEL if exist "%CD%\models\gemma-4-E4B_q4_0-it.gguf" set "GEMMA4_MODEL=%CD%\models\gemma-4-E4B_q4_0-it.gguf"
if not defined GEMMA4_MMPROJ if exist "%CD%\models\gemma-4-E4B-it-mmproj.gguf" set "GEMMA4_MMPROJ=%CD%\models\gemma-4-E4B-it-mmproj.gguf"

set "GEMMA4_HF_CACHE=%USERPROFILE%\.cache\huggingface\hub\models--google--gemma-4-E4B-it-qat-q4_0-gguf\snapshots"
if not defined GEMMA4_MODEL if exist "%GEMMA4_HF_CACHE%" (
  for /d %%D in ("%GEMMA4_HF_CACHE%\*") do (
    if not defined GEMMA4_MODEL if exist "%%~fD\gemma-4-E4B_q4_0-it.gguf" set "GEMMA4_MODEL=%%~fD\gemma-4-E4B_q4_0-it.gguf"
    if not defined GEMMA4_MMPROJ if exist "%%~fD\gemma-4-E4B-it-mmproj.gguf" set "GEMMA4_MMPROJ=%%~fD\gemma-4-E4B-it-mmproj.gguf"
  )
)

if not defined GEMMA4_MODEL set "GEMMA4_MODEL=%CD%\models\gemma-4-E4B_q4_0-it.gguf"
if not defined GEMMA4_MMPROJ set "GEMMA4_MMPROJ=%CD%\models\gemma-4-E4B-it-mmproj.gguf"
if "%GEMMA4_HOST%"=="" set "GEMMA4_HOST=127.0.0.1"
if "%GEMMA4_PORT%"=="" set "GEMMA4_PORT=18080"
if "%GEMMA4_ALIAS%"=="" set "GEMMA4_ALIAS=gemma4-codex"
if "%GEMMA4_CTX_SIZE%"=="" set "GEMMA4_CTX_SIZE=16384"
if "%GEMMA4_GPU_LAYERS%"=="" set "GEMMA4_GPU_LAYERS=999"
if "%GEMMA4_LOG%"=="" set "GEMMA4_LOG=%CD%\gemma4-codex-server.log"

if not exist "%GEMMA4_LLAMA_SERVER%" (
  echo llama-server.exe not found:
  echo   %GEMMA4_LLAMA_SERVER%
  echo.
  echo Set GEMMA4_LLAMA_SERVER to your llama-server.exe path, or place llama-server.exe at:
  echo   %CD%\llama-cpp\llama-server.exe
  exit /b 1
)

if not exist "%GEMMA4_MODEL%" (
  echo Gemma model file not found:
  echo   %GEMMA4_MODEL%
  echo.
  echo Set GEMMA4_MODEL to your .gguf model path, or place the model at:
  echo   %CD%\models\gemma-4-E4B_q4_0-it.gguf
  exit /b 1
)

del "%GEMMA4_LOG%" >nul 2>nul

echo Starting Gemma 4 Codex server.
echo.
echo Endpoint:
echo   http://%GEMMA4_HOST%:%GEMMA4_PORT%/v1
echo.
echo Model alias:
echo   %GEMMA4_ALIAS%
echo.
echo Context window:
echo   %GEMMA4_CTX_SIZE%
echo.
echo Keep this window open while Codex is using the local model.
echo Log file:
echo   %GEMMA4_LOG%
echo.
echo llama-server:
echo   %GEMMA4_LLAMA_SERVER%
echo.
echo model:
echo   %GEMMA4_MODEL%
echo.

if exist "%GEMMA4_MMPROJ%" (
  "%GEMMA4_LLAMA_SERVER%" ^
    -m "%GEMMA4_MODEL%" ^
    --mmproj "%GEMMA4_MMPROJ%" ^
    --host "%GEMMA4_HOST%" ^
    --port "%GEMMA4_PORT%" ^
    --ctx-size "%GEMMA4_CTX_SIZE%" ^
    --n-gpu-layers "%GEMMA4_GPU_LAYERS%" ^
    --jinja ^
    --reasoning off ^
    --alias "%GEMMA4_ALIAS%" ^
    --log-file "%GEMMA4_LOG%"
) else (
  echo Gemma multimodal projector not found. Starting text-only server.
  echo Missing projector path:
  echo   %GEMMA4_MMPROJ%
  echo.
  "%GEMMA4_LLAMA_SERVER%" ^
    -m "%GEMMA4_MODEL%" ^
    --host "%GEMMA4_HOST%" ^
    --port "%GEMMA4_PORT%" ^
    --ctx-size "%GEMMA4_CTX_SIZE%" ^
    --n-gpu-layers "%GEMMA4_GPU_LAYERS%" ^
    --jinja ^
    --reasoning off ^
    --alias "%GEMMA4_ALIAS%" ^
    --log-file "%GEMMA4_LOG%"
)

set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo Gemma 4 Codex server stopped with exit code %EXIT_CODE%.
exit /b %EXIT_CODE%
