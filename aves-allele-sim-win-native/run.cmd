@echo off
setlocal EnableExtensions

REM Entrypoint principal (Windows nativo, sem PowerShell/ExecutionPolicy)
cd /d "%~dp0"

set "VENV_DIR=.venv"
set "PY_EXE=%VENV_DIR%\Scripts\python.exe"

REM 1) Criar venv se necess??rio
if exist "%PY_EXE%" goto :deps

echo [INFO] Criando ambiente virtual em "%VENV_DIR%"...

where py >nul 2>nul
if errorlevel 1 goto :try_python

py -3.12 -m venv "%VENV_DIR%"
if not errorlevel 1 goto :check_venv

py -3.11 -m venv "%VENV_DIR%"
if not errorlevel 1 goto :check_venv

py -3 -m venv "%VENV_DIR%"
if errorlevel 1 goto :try_python
goto :check_venv

:try_python
echo [AVISO] Launcher "py" indisponivel. Tentando "python"...
python -m venv "%VENV_DIR%"
if errorlevel 1 goto :no_python

:check_venv
if exist "%PY_EXE%" goto :deps
goto :no_python

:no_python
echo [ERRO] Python nao encontrado. Instale Python 3.11+ e tente novamente.
echo        Dica: instale pelo site oficial do Python (python.org) e habilite "Add to PATH".
exit /b 1

REM 2) Depend??ncias
:deps
echo [INFO] Instalando/atualizando dependencias. A primeira vez pode demorar...
"%PY_EXE%" -m pip install --upgrade pip >nul 2>nul
echo [INFO] Instalando "pysam" (somente binario; sem compilacao)...
"%PY_EXE%" -m pip install --only-binary=:all: "pysam>=0.22"
if errorlevel 1 goto :pysam_fail

echo [INFO] Instalando demais dependencias...
"%PY_EXE%" -m pip install -r "requirements.txt"
if errorlevel 1 goto :pip_fail

REM 3) Execu????o
echo [INFO] Executando...
"%PY_EXE%" -m src.main --config "config.yaml" %*
exit /b %ERRORLEVEL%

:pip_fail
echo [ERRO] Falha ao instalar dependencias. Verifique sua conexao e permissao de escrita.
exit /b 1

:pysam_fail
echo [ERRO] Falha ao instalar "pysam" como binario (wheel).
echo        Isso costuma acontecer quando sua versao do Python e muito nova e nao existe wheel no PyPI.
echo        Solucao recomendada: instale Python 3.12 (ou 3.11) pelo python.org e rode novamente.
exit /b 1