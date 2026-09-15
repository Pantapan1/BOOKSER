# BOKSER — Flutter (нативный APK), backend Firebase (book-2b50d)

Нативный Flutter-клиент поверх **того же** Firebase Realtime Database проекта,
что и текущая веб-версия (`book-2b50d`). Никакой миграции данных не требуется —
приложение читает и пишет по тем же путям (`users/`, `auth_users/`, `posts/`,
`chats/`), что и оригинальный `core.js` / `feed.js` / `chats.js`.

## Статус: MVP (фаза 1)

Готово:
- Вход/регистрация по логину и паролю (`auth_users/{username}` + SHA-256,
  полностью совместимо со старыми аккаунтами, включая legacy-пароли открытым
  текстом — как и в оригинале, при успешном входе они домигрируются на хэш).
- Лента постов (просмотр в реальном времени + публикация текстового поста).
- Профиль (имя, монеты, аватар, выход).
- Чаты: список, direct-переписка 1-на-1 в реальном времени, старт нового чата
  через список пользователей.

Не реализовано (следующие фазы, беритесь по одному модулю за раз):
- Загрузка изображений в постах/сообщениях (imgbb/Cloudinary — как в оригинале).
- Групповые чаты, ролевые панели, вики, стикеры, кинотеатр (весь `chats.js`
  кроме direct-переписки).
- Книги/новеллы + редактор, стрики, закладки (`books.js`).
- Карточная боевая система, деки, арена, сюжетные боссы (`cards.js`, `decks.js`,
  `battle.js`, `story.js`).
- Сезонный пасс, магазин, квесты, экономика (`pass.js`, `shop.js`).
- Админ-панель, форма заявки издателя (`admin.js`, `publisher-application.html`).
- Push-уведомления через Telegram-бота (замена `functions/index.js`). Экран
  профиля уже содержит заглушку "Привязать Telegram" под это.

## Настройка перед первым запуском

1. **Firebase уже настроен** — используется существующий проект `book-2b50d`
   и Android-приложение `bokser.rlteam.com` (см. `firebase/google-services.json`,
   тот же файл, что был в вашей старой Capacitor-сборке). Ничего создавать не
   нужно.
2. Данные подключения вписаны в `lib/core/firebase_options.dart` вручную из
   `google-services.json`. Если когда-нибудь понадобится iOS или Web —
   зарегистрируйте платформу в консоли Firebase и добавьте её блок туда же
   (или один раз выполните `flutterfire configure`, если поставите Firebase CLI
   — он сделает это автоматически для всех платформ).
3. Локальная разработка:
   ```
   flutter create --platforms=android .   # один раз, генерирует android/
   cp firebase/google-services.json android/app/google-services.json
   flutter pub get
   flutter run
   ```
   (Не забудьте подключить плагин `com.google.gms.google-services` в
   `android/settings.gradle`/`android/app/build.gradle` — см. шаги в
   `.github/workflows/build-apk.yml`, там это делается автоматически для CI.)

## Сборка APK через GitHub Actions

Пушьте в ветку `main` — `.github/workflows/build-apk.yml`
сам сгенерирует `android/`, подключит `google-services.json` и Gradle-плагин
Firebase, соберёт debug APK и приложит его как артефакт `BOKSER-debug`.

## Почему не Appwrite

Изначально обсуждали переход на Appwrite, но решили оставить существующий
Firebase-проект — все данные уже там, миграция не нужна, экономит время.
Если решите вернуться к идее Appwrite — потребуется отдельная миграция
данных и переписывание `lib/services/*` под Appwrite SDK.
