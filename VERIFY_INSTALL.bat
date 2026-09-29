@echo off
setlocal
pushd "%~dp0"
echo GOVINNOVATE installation check
echo Root: %CD%
echo.
if exist "backend\requirements.txt" (echo [OK] backend\requirements.txt) else (echo [MISSING] backend\requirements.txt)
if exist "backend\app\main.py" (echo [OK] backend\app\main.py) else (echo [MISSING] backend\app\main.py)
if exist "frontend\package.json" (echo [OK] frontend\package.json) else (echo [MISSING] frontend\package.json)
if exist "frontend\src\main.jsx" (echo [OK] frontend\src\main.jsx) else (echo [MISSING] frontend\src\main.jsx)
echo.
pause
popd
