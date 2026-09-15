# Распаковывает bokser-flutter-mvp.zip прямо в ваш git-репозиторий и пушит в ветку app.
#
# ИСПОЛЬЗОВАНИЕ (PowerShell):
#   1. Положите этот файл и bokser-flutter-mvp.zip рядом с папкой репозитория.
#   2. Откройте PowerShell в этой папке.
#   3. Если репозиторий ещё не склонирован:
#        git clone https://github.com/ВАШ_ЛОГИН/ВАШ_РЕПО.git
#   4. Запустите:
#        .\deploy_to_repo.ps1 -ZipFile "bokser-flutter-mvp.zip" -RepoDir "путь\до\репозитория"
#
# Что делает: распаковывает архив поверх репозитория (перезаписывая совпадающие
# файлы), создаёт/переключает ветку app, коммитит и пушит.

param(
    [string]$ZipFile = "bokser-flutter-mvp.zip",
    [string]$RepoDir = "."
)

if (-not (Test-Path $ZipFile)) {
    Write-Host "Не найден файл $ZipFile. Укажите путь параметром -ZipFile" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path (Join-Path $RepoDir ".git"))) {
    Write-Host "$RepoDir — это не git-репозиторий (нет папки .git)." -ForegroundColor Red
    Write-Host "Сначала склонируйте свой репозиторий: git clone <url>"
    exit 1
}

Write-Host "Распаковываю $ZipFile в $RepoDir ..."
Expand-Archive -Path $ZipFile -DestinationPath $RepoDir -Force

Set-Location $RepoDir

Write-Host "Переключаюсь на ветку main ..."
git checkout -B main

Write-Host "Добавляю файлы ..."
git add -A

$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host "Изменений нет — нечего коммитить."
    exit 0
}

git commit -m "BOKSER: Flutter MVP (лента, профиль, чаты) на Firebase"

Write-Host "Пушу в origin/main ..."
git push -u origin main

Write-Host "Готово! Смотрите вкладку Actions в репозитории на GitHub." -ForegroundColor Green
