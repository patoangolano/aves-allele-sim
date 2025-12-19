param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Args
)

$ErrorActionPreference = "Stop"

Set-Location -Path $PSScriptRoot

$venvDir = ".venv"
$pythonExe = Join-Path $venvDir "Scripts\\python.exe"

if (-not (Test-Path $venvDir)) {
  Write-Host "[INFO] Criando ambiente virtual em '$venvDir'..."
  $created = $false
  foreach ($spec in @("-3.12", "-3.11", "-3")) {
    try {
      py $spec -m venv $venvDir
      $created = $true
      break
    } catch {
      # continua
    }
  }
  if (-not $created) {
    Write-Host "[AVISO] Launcher 'py' indisponivel. Tentando 'python'..."
    python -m venv $venvDir
  }
}

if (-not (Test-Path $pythonExe)) {
  throw "Ambiente virtual incompleto: '$pythonExe' nao existe."
}

Write-Host "[INFO] Instalando/atualizando dependencias (primeira vez pode demorar)..."
& $pythonExe -m pip install --upgrade pip *> $null
Write-Host "[INFO] Instalando 'pysam' (somente binario; sem compilacao)..."
& $pythonExe -m pip install --only-binary=:all: "pysam>=0.22"
if ($LASTEXITCODE -ne 0) {
  throw "Falha ao instalar 'pysam' como wheel. Solucao recomendada: use Python 3.12 (ou 3.11) do python.org."
}

Write-Host "[INFO] Instalando demais dependencias..."
& $pythonExe -m pip install -r "requirements.txt"

Write-Host "[INFO] Executando..."
& $pythonExe -m src.main --config "config.yaml" @Args
