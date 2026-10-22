# 📰 Daily Pulse

**Your daily news, in brief.**

A clean news app for Android, built with **Flutter**, **Provider** and **NewsAPI.org**.
Browse top headlines by category, search the news, save stories for later, and read them in light or dark mode — even offline.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Provider-D32F2F)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Tests](https://img.shields.io/badge/Unit%20tests-46%20passing-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

> Built in one week as a **practice brief** for a Flutter intern role (a mock assignment I set for myself to learn Flutter fast).

---

## 📥 Download & Demo

| | |
|---|---|
| 📱 **Release APK** | _Coming soon_ (GitHub Releases) |
| 🎥 **Demo video** | _Coming soon_ (YouTube) |

---

## 📸 Screenshots

<table>
  <tr>
    <td align="center"><img src="screenshots/onboarding.png" width="220"><br><b>Welcome</b></td>
    <td align="center"><img src="screenshots/interests.png" width="220"><br><b>Choose interests</b></td>
    <td align="center"><img src="screenshots/home_light.png" width="220"><br><b>Home</b></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/details.png" width="220"><br><b>News details</b></td>
    <td align="center"><img src="screenshots/explore.png" width="220"><br><b>Explore</b></td>
    <td align="center"><img src="screenshots/live_search.png" width="220"><br><b>Live search</b></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/saved.png" width="220"><br><b>Saved</b></td>
    <td align="center"><img src="screenshots/settings.png" width="220"><br><b>Settings</b></td>
    <td align="center"><img src="screenshots/offline.png" width="220"><br><b>Offline mode</b></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/home_dark.png" width="220"><br><b>Home (dark)</b></td>
    <td align="center"><img src="screenshots/details_dark.png" width="220"><br><b>Details (dark)</b></td>
    <td></td>
  </tr>
</table>

---

## ✨ Features

### Required

| Feature | What it does |
|---|---|
| 🏠 **Home** | Auto-sliding banner (top 5 stories) + Latest News list with image, title, source and time |
| 📰 **News details** | Big image, title, source, date, description, **Read full article** (in-app WebView or browser) |
| 🗂️ **Categories** | General, Business, Technology, Sports, Health, Science, Entertainment + **Sri Lanka** |
| 🔍 **Search** | Search any topic, with recent searches and trending topics |
| 🔖 **Bookmarks** | Save stories. They stay after the app closes. Undo and Clear all |
| ⏳ **Loading & errors** | Spinners, friendly error messages, "Try again" buttons |
| 🔄 **Pull to refresh** | Pull down on Home to load fresh news |

### Bonus

| Feature | What it does |
|---|---|
| 🌙 **Dark mode** | Light / Dark / System. Your choice is saved |
| 📤 **Share** | Share a story's link to any app |
| 📜 **Pagination** | More news loads as you scroll (Home and Search) |
| 🧪 **Unit tests** | 46 tests for the model, the API service and helpers |

### Extras

- 👋 **Welcome screens** — pick your news interests; they move to the front of the Home tabs.
- 📴 **Offline mode** — the last news of each category is saved on the phone and shown when there is no internet.
- 💡 **Live search suggestions** — while you type: recent words, topics and words from loaded titles (the guessed part is highlighted in blue). It also finds matches in news already on the phone.
- 🧭 **Explore tab** — category grid, popular topics and top stories.
- 🔗 **Related news** on the details page.
- 🖼️ **Smart image placeholders** — when a story has no image, a colored box shows the short source name (like `WSJ` or `BBC`).
- ⚡ **API saver** — each category is cached for 15 minutes, so switching tabs does not waste API requests.
- ⚙️ **Settings** — change interests, show the welcome screens again, clear search history, clear cached news, app version and links.

---

## 🚀 Setup

### 1. What you need

- Flutter 3.x (Dart 3)
- An Android phone or emulator
- A free API key from [newsapi.org/register](https://newsapi.org/register)

### 2. Get the code

```bash
git clone https://github.com/SandaruwanChandrasena/daily-pulse.git
cd daily-pulse
```

### 3. Add your API key

The real key file is **not** on GitHub (it is in `.gitignore`).

1. Copy `lib/config/api_keys.example.dart`
2. Rename the copy to `lib/config/api_keys.dart`
3. Paste your key:

```dart
class ApiKeys {
  static const String newsApiKey = 'YOUR_KEY_HERE';
}
```

### 4. Run

```bash
flutter pub get
flutter run
```

To build the release APK:

```bash
flutter build apk --release
```

The APK is at `build/app/outputs/flutter-apk/app-release.apk`.

> ⚠️ Please run the app on **Android**. NewsAPI's free plan blocks requests from a web browser.

---

## 📦 Packages Used

| Package | Why |
|---|---|
| [`http`](https://pub.dev/packages/http) | Calls NewsAPI |
| [`provider`](https://pub.dev/packages/provider) | State management |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Saves bookmarks, history, theme, interests and offline news |
| [`cached_network_image`](https://pub.dev/packages/cached_network_image) | Loads and caches news images |
| [`url_launcher`](https://pub.dev/packages/url_launcher) | Opens links in the browser |
| [`webview_flutter`](https://pub.dev/packages/webview_flutter) | Reads the full article inside the app |
| [`share_plus`](https://pub.dev/packages/share_plus) | Shares a story |
| [`package_info_plus`](https://pub.dev/packages/package_info_plus) | Shows the app version in Settings |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Archivo (titles) and Inter (body text) |
| [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) | Makes the app icon (dev only) |

> `shared_preferences_android` is pinned below `2.5.0`. Version 2.5.x had a bug where saving did not work in **release** builds (R8 renamed some classes). See [LEARNING_LOG.md](LEARNING_LOG.md) for the full story.

---

## 🗂️ Project Structure

```
lib/
├── main.dart            # Providers, theme, start screen
├── config/              # Theme, API key, app info, topic lists
├── models/              # Article, NewsCategory, NewsPage, Suggestion
├── services/            # NewsAPI calls, cache, bookmarks, history, settings
├── providers/           # News, Search, Bookmark, Theme, Onboarding, Navigation
├── screens/             # Home, Explore, Search, Saved, Settings, Details, WebView, Welcome
├── utils/               # Dates, search suggestions, source colors, dialogs
└── widgets/
    ├── common/          # Titles, empty/error views, info bar, load-more footer
    ├── news/            # List tile, image, banner, bookmark button, badge
    ├── category/        # Tabs, chips, cards, interest picker
    └── search/          # Search box, recent searches, suggestions, topic chips
test/
├── models/
├── services/            # Uses a fake server (MockClient), no real API calls
└── utils/
```

### How the code is organized

- **Screens** only show things. They read data from **providers**.
- **Providers** hold the app state and call **services**.
- **Services** talk to NewsAPI or save data on the phone.
- **Models** turn JSON into Dart objects.

```
Screen  →  Provider  →  Service  →  NewsAPI / phone storage
   ↑           │
   └── notifyListeners() rebuilds the screen
```

---

## 🧪 Testing

```bash
flutter test
```

- 46 unit tests: article model, categories, API service (with a fake server), dates, search suggestions and source styles.
- The tests use **no internet** and **no API requests**.
- The full **manual test plan** (release mode, on a real phone) is in [TESTING.md](TESTING.md).

---

## ℹ️ Good to Know (NewsAPI free plan)

| Limit | What it means in the app |
|---|---|
| **100 requests per day** | Categories are cached for 15 minutes to save requests |
| **Search results are at least 1 day old** | Search and the **Sri Lanka** tab show stories from yesterday or before |
| **Max 100 results per query** | "Load more" stops after 100 stories ("You're all caught up") |
| **No Sri Lanka top headlines** | The Sri Lanka tab searches for `"Sri Lanka"` in titles instead |
| **Top headlines are from the US** | Uses `country=us` |

### Honest notes

- **Trending** and **popular** topics are fixed lists. NewsAPI has no trending feature.
- The details page shows the **short description** from NewsAPI. Tap **Read full article** for the full story.
- Fonts download on the **first launch** (needs internet once), then they are cached.
- Tested on a real Android phone (Realme RMX2195).

---

## 📝 What I Learned

All the problems I hit and how I fixed them are in **[LEARNING_LOG.md](LEARNING_LOG.md)**.

---

## 🙏 Credits

- News data by [NewsAPI.org](https://newsapi.org)
- Fonts: [Archivo](https://fonts.google.com/specimen/Archivo) and [Inter](https://fonts.google.com/specimen/Inter) from Google Fonts
- Icons: Material Icons

---

## 👤 Author

**Sandaruwan Chandrasena**

- 🐙 GitHub: [@SandaruwanChandrasena](https://github.com/SandaruwanChandrasena)
- 🎥 YouTube: [@SandaruwanChandrasena-98](https://www.youtube.com/@SandaruwanChandrasena-98)
- 💼 LinkedIn: [sandaruwanchandrasena](https://www.linkedin.com/in/sandaruwanchandrasena)

---

## 📄 License

This project is under the [MIT License](LICENSE).