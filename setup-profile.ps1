# GitHub Profile Setup Automation Script
# Este script ayuda a configurar tu perfil de GitHub con el README mejorado

Write-Host "`n🚀 GitHub Profile README Setup Helper" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# Variables
$username = "CamiloTriana75"
$repoName = $username
$currentDir = Get-Location
$sourceReadme = Join-Path $currentDir "README.md"
$sourceWorkflow = Join-Path $currentDir ".github\workflows\snake.yml"

Write-Host "📋 Pre-requisitos:" -ForegroundColor Yellow
Write-Host "   ✅ Git instalado"
Write-Host "   ✅ Autenticado en GitHub"
Write-Host "   ✅ Repositorio '$repoName' creado en GitHub`n"

# Verificar si Git está instalado
try {
    $gitVersion = git --version
    Write-Host "✅ Git detectado: $gitVersion`n" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Git no está instalado o no está en PATH" -ForegroundColor Red
    Write-Host "   Descarga Git desde: https://git-scm.com/download/win`n" -ForegroundColor Yellow
    exit 1
}

# Preguntar si el repositorio ya existe
Write-Host "¿Ya creaste el repositorio '$repoName' en GitHub? (S/N): " -ForegroundColor Yellow -NoNewline
$repoExists = Read-Host

if ($repoExists -ne "S" -and $repoExists -ne "s") {
    Write-Host "`n⚠️  Primero debes crear el repositorio en GitHub:" -ForegroundColor Yellow
    Write-Host "   1. Ve a: https://github.com/new" -ForegroundColor Cyan
    Write-Host "   2. Nombre: $username (exactamente igual a tu username)" -ForegroundColor Cyan
    Write-Host "   3. Marca como público" -ForegroundColor Cyan
    Write-Host "   4. ✅ Inicializa con README" -ForegroundColor Cyan
    Write-Host "   5. Crea el repositorio`n" -ForegroundColor Cyan
    
    Write-Host "Presiona Enter cuando hayas creado el repositorio..." -ForegroundColor Yellow
    Read-Host
}

# Preguntar dónde clonar
Write-Host "`n📁 ¿Dónde quieres clonar el repositorio?" -ForegroundColor Yellow
Write-Host "   Ruta actual: $currentDir" -ForegroundColor Cyan
Write-Host "   (Presiona Enter para usar una carpeta temporal o escribe la ruta): " -NoNewline
$clonePath = Read-Host

if ([string]::IsNullOrWhiteSpace($clonePath)) {
    $clonePath = Join-Path $env:TEMP "github-profile-setup"
    Write-Host "   Usando: $clonePath" -ForegroundColor Cyan
}

# Crear directorio si no existe
if (-not (Test-Path $clonePath)) {
    New-Item -ItemType Directory -Path $clonePath -Force | Out-Null
    Write-Host "✅ Directorio creado: $clonePath`n" -ForegroundColor Green
}

# Cambiar al directorio
Set-Location $clonePath

# Clonar el repositorio
Write-Host "`n🔄 Clonando repositorio..." -ForegroundColor Cyan
$repoUrl = "https://github.com/$username/$repoName.git"

if (Test-Path $repoName) {
    Write-Host "⚠️  El directorio '$repoName' ya existe. Eliminándolo..." -ForegroundColor Yellow
    Remove-Item -Path $repoName -Recurse -Force
}

try {
    git clone $repoUrl
    Set-Location $repoName
    Write-Host "✅ Repositorio clonado exitosamente`n" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al clonar el repositorio" -ForegroundColor Red
    Write-Host "   Verifica que el repositorio existe y tienes acceso`n" -ForegroundColor Yellow
    Set-Location $currentDir
    exit 1
}

# Copiar README.md
Write-Host "📄 Copiando README.md actualizado..." -ForegroundColor Cyan
if (Test-Path $sourceReadme) {
    Copy-Item -Path $sourceReadme -Destination "README.md" -Force
    Write-Host "✅ README.md copiado`n" -ForegroundColor Green
} else {
    Write-Host "⚠️  Advertencia: No se encontró $sourceReadme" -ForegroundColor Yellow
}

# Crear estructura de carpetas para workflow
Write-Host "📁 Creando estructura para GitHub Actions..." -ForegroundColor Cyan
$workflowDir = ".github\workflows"
if (-not (Test-Path $workflowDir)) {
    New-Item -ItemType Directory -Path $workflowDir -Force | Out-Null
}

# Copiar workflow de snake animation
if (Test-Path $sourceWorkflow) {
    Copy-Item -Path $sourceWorkflow -Destination "$workflowDir\snake.yml" -Force
    Write-Host "✅ Workflow snake.yml copiado`n" -ForegroundColor Green
} else {
        Write-Host "WARNING: Workflow not found at $sourceWorkflow" -ForegroundColor Yellow
        Write-Host "Creating workflow from scratch...`n" -ForegroundColor Yellow

$workflowContent = @'
name: Generate Snake Animation

on:
    schedule:
        - cron: "0 */24 * * *"
    workflow_dispatch:
    push:
        branches:
        - main

jobs:
    generate:
        permissions:
            contents: write
        runs-on: ubuntu-latest
        timeout-minutes: 5
    
        steps:
            - name: Generate github-contribution-grid-snake.svg
                uses: Platane/snk/svg-only@v3
                with:
                    github_user_name: ${{ github.repository_owner }}
                    outputs: |
                        dist/github-contribution-grid-snake.svg
                        dist/github-contribution-grid-snake-dark.svg?palette=github-dark
                env:
                    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          
            - name: Push github-contribution-grid-snake.svg to output branch
                uses: crazy-max/ghaction-github-pages@v3.1.0
                with:
                    target_branch: output
                    build_dir: dist
                env:
                    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
'@
    
    Set-Content -Path "$workflowDir\snake.yml" -Value $workflowContent
    Write-Host "OK: Workflow created`n" -ForegroundColor Green
}

# Git add, commit y push
Write-Host "📤 Preparando commit..." -ForegroundColor Cyan
git add .
git commit -m "✨ Add animated profile README with snake animation"

Write-Host "`n🚀 ¿Deseas hacer push ahora? (S/N): " -ForegroundColor Yellow -NoNewline
$doPush = Read-Host

if ($doPush -eq "S" -or $doPush -eq "s") {
    Write-Host "`n📤 Haciendo push a GitHub..." -ForegroundColor Cyan
    try {
        git push origin main
        Write-Host "✅ Push exitoso!`n" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al hacer push. Intenta manualmente con: git push origin main`n" -ForegroundColor Red
    }
} else {
    Write-Host "`n⚠️  Recuerda hacer push manualmente:" -ForegroundColor Yellow
    Write-Host "   cd $(Get-Location)" -ForegroundColor Cyan
    Write-Host "   git push origin main`n" -ForegroundColor Cyan
}

# Instrucciones finales
Write-Host "`n✨ ¡Configuración completada!" -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green

Write-Host "📋 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Ve a: https://github.com/$username/$repoName/actions" -ForegroundColor Cyan
Write-Host "   2. Click en 'Generate Snake Animation'" -ForegroundColor Cyan
Write-Host "   3. Click en 'Run workflow' → 'Run workflow' (botón verde)" -ForegroundColor Cyan
Write-Host "   4. Espera 1-2 minutos" -ForegroundColor Cyan
Write-Host "   5. ¡Visita tu perfil!: https://github.com/$username`n" -ForegroundColor Cyan

Write-Host "🎵 Configuración opcional de Spotify:" -ForegroundColor Yellow
Write-Host "   - Lee las instrucciones en: PROFILE_SETUP_INSTRUCTIONS.md`n" -ForegroundColor Cyan

Write-Host "🔗 Enlaces útiles:" -ForegroundColor Yellow
Write-Host "   - Tu perfil: https://github.com/$username" -ForegroundColor Cyan
Write-Host "   - Repositorio: https://github.com/$username/$repoName" -ForegroundColor Cyan
Write-Host "   - GitHub Actions: https://github.com/$username/$repoName/actions`n" -ForegroundColor Cyan

# Preguntar si abrir en navegador
Write-Host "¿Deseas abrir GitHub Actions en el navegador? (S/N): " -ForegroundColor Yellow -NoNewline
$openBrowser = Read-Host

if ($openBrowser -eq "S" -or $openBrowser -eq "s") {
    Start-Process "https://github.com/$username/$repoName/actions"
}

Write-Host "`nOK. Thanks for using this script.`n" -ForegroundColor Green

# Volver al directorio original
Set-Location $currentDir
