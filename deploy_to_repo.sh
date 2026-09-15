#!/usr/bin/env bash
# Распаковывает bokser-flutter-mvp.zip прямо в ваш git-репозиторий и пушит в ветку app.
#
# ИСПОЛЬЗОВАНИЕ:
#   1. Положите этот файл и bokser-flutter-mvp.zip рядом с папкой репозитория
#      (или укажите пути явно, см. ниже).
#   2. Откройте терминал (на Windows — Git Bash) в этой папке.
#   3. Запустите:  bash deploy_to_repo.sh /путь/до/вашего/репозитория
#      Если репозиторий ещё не склонирован — сначала:
#        git clone https://github.com/ВАШ_ЛОГИН/ВАШ_РЕПО.git
#
# Что делает: распаковывает архив поверх репозитория (перезаписывая совпадающие
# файлы), создаёт/переключает ветку app, коммитит и пушит.

set -e

ZIP_FILE="${1:-bokser-flutter-mvp.zip}"
REPO_DIR="${2:-.}"

if [ ! -f "$ZIP_FILE" ]; then
  echo "❌ Не найден файл $ZIP_FILE. Укажите путь первым аргументом:"
  echo "   bash deploy_to_repo.sh /путь/до/bokser-flutter-mvp.zip /путь/до/репозитория"
  exit 1
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "❌ $REPO_DIR — это не git-репозиторий (нет папки .git)."
  echo "   Сначала склонируйте свой репозиторий: git clone <url>"
  echo "   Затем запустите: bash deploy_to_repo.sh $ZIP_FILE /путь/до/склонированного/репо"
  exit 1
fi

echo "📦 Распаковываю $ZIP_FILE в $REPO_DIR ..."
unzip -o "$ZIP_FILE" -d "$REPO_DIR" > /dev/null

cd "$REPO_DIR"

echo "🌿 Переключаюсь на ветку main ..."
git checkout -B main

echo "➕ Добавляю файлы ..."
git add -A

if git diff --cached --quiet; then
  echo "ℹ️  Изменений нет — нечего коммитить."
  exit 0
fi

git commit -m "BOKSER: Flutter MVP (лента, профиль, чаты) на Firebase"

echo "🚀 Пушу в origin/main ..."
git push -u origin main

echo "✅ Готово! GitHub Actions должен запуститься автоматически — смотрите вкладку Actions в репозитории."
