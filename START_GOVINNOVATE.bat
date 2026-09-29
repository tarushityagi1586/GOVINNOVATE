@echo off
setlocal EnableExtensions
pushd "%~dp0"
set "ROOT=%CD%"
title GOVINNOVATE - SIH 26136
color 5F

echo ============================================
echo        GOVINNOVATE - SIH 26136
echo ============================================
echo Working directory: %ROOT%
echo.

python --version >nul 2>&1
if errorlevel 1 (echo ERROR: Python is not installed or not in PATH.& pause& popd& exit /b 1)
where npm >nul 2>&1
if errorlevel 1 (echo ERROR: Node.js/npm is not installed or not in PATH.& pause& popd& exit /b 1)

if not exist "%ROOT%\backend" mkdir "%ROOT%\backend"
if not exist "%ROOT%\backend\requirements.txt" (
 echo Recreating backend requirements...
 >"%ROOT%\backend\requirements.txt" echo fastapi
 >>"%ROOT%\backend\requirements.txt" echo uvicorn
 >>"%ROOT%\backend\requirements.txt" echo pandas
 >>"%ROOT%\backend\requirements.txt" echo pydantic
 >>"%ROOT%\backend\requirements.txt" echo reportlab
 >>"%ROOT%\backend\requirements.txt" echo qrcode
 >>"%ROOT%\backend\requirements.txt" echo Pillow
)
if not exist "%ROOT%\backend\govinnovate_app.py" (
 echo ERROR: Backend application file is missing after extraction.
 echo Expected: %ROOT%\backend\govinnovate_app.py
 echo Please extract the complete ZIP before running this file.
 pause& popd& exit /b 1
)

if not exist "%ROOT%\backend\venv\Scripts\python.exe" (
 echo Creating backend virtual environment...
 python -m venv "%ROOT%\backend\venv"
 if errorlevel 1 (echo ERROR: Failed to create virtual environment.& pause& popd& exit /b 1)
)

echo Installing/checking backend packages...
call "%ROOT%\backend\venv\Scripts\python.exe" -m pip install -r "%ROOT%\backend\requirements.txt"
if errorlevel 1 (echo ERROR: Backend package installation failed.& pause& popd& exit /b 1)

if not exist "%ROOT%\frontend" mkdir "%ROOT%\frontend"
if not exist "%ROOT%\frontend\package.json" (
 echo Recreating frontend package manifest...
 >"%ROOT%\frontend\package.json" echo {"name":"govinnovate","private":true,"version":"1.0.0","type":"module","scripts":{"dev":"vite","build":"vite build"},"dependencies":{"react":"latest","react-dom":"latest","react-router-dom":"latest","lucide-react":"latest","recharts":"latest","vite":"latest","@vitejs/plugin-react":"latest"},"devDependencies":{}}
)
if not exist "%ROOT%\frontend\src\main.jsx" (echo ERROR: frontend\src\main.jsx is missing.& pause& popd& exit /b 1)

if not exist "%ROOT%\frontend\node_modules\vite\bin\vite.js" (
 echo Installing frontend packages. This happens only on first run...
 pushd "%ROOT%\frontend"
 call npm install --no-audit --no-fund
 if errorlevel 1 (echo ERROR: Frontend package installation failed.& popd& pause& popd& exit /b 1)
 popd
) else echo Frontend packages already installed.

echo Clearing old development ports...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ports=8000,5173; foreach($p in $ports){$c=Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue; foreach($x in $c){Stop-Process -Id $x.OwningProcess -Force -ErrorAction SilentlyContinue}}"

echo Starting backend...
start "GOVINNOVATE Backend" cmd /k "cd /d "%ROOT%\backend" && "%ROOT%\backend\venv\Scripts\python.exe" -m uvicorn --app-dir "%ROOT%\backend" govinnovate_app:app --host 127.0.0.1 --port 8000"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ok=$false; for($i=0;$i-lt60;$i++){try{$r=Invoke-WebRequest 'http://127.0.0.1:8000/api/health' -UseBasicParsing -TimeoutSec 1;if($r.StatusCode -eq 200){$ok=$true;break}}catch{};Start-Sleep -Milliseconds 500}; if($ok){exit 0}else{exit 1}"
if errorlevel 1 (echo ERROR: Backend did not start. Check the backend window.& pause& popd& exit /b 1)

echo Starting frontend...
start "GOVINNOVATE Frontend" cmd /k "cd /d "%ROOT%\frontend" && npm run dev -- --host 127.0.0.1 --port 5173"
timeout /t 4 /nobreak >nul
start "" http://localhost:5173

echo.
echo ============================================
echo GOVINNOVATE is running.
echo Browser: http://localhost:5173
echo API:     http://127.0.0.1:8000/api/health
echo ============================================
echo Keep both server windows open.
echo.
pause
popd
