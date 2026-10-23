# 🧪 Daily Pulse — Testing

Daily Pulse is tested in two ways:

| Type | What it is | How |
|---|---|---|
| 🤖 **Unit tests** | Automatic tests for the logic | `flutter test` |
| 📱 **Manual test plan** | A checklist to test the real app on a phone | `flutter run --release` |

## 🤖 Unit Tests

### ▶️ How to run

```bash
flutter test
```

> [!IMPORTANT]
> You need `lib/config/api_keys.dart` first (copy `api_keys.example.dart`).

> [!NOTE]
> The tests **never call the real NewsAPI**. They use a fake server (`MockClient`), so they need no internet and use none of the 100 daily requests.

### 📋 What is tested

| Test file | What it checks |
|---|---|
| `test/models/article_test.dart` | `fromJson` reads NewsAPI JSON, safe defaults for null fields, removes `" - Source"` from titles, `toJson` → `fromJson` gives the same article |
| `test/models/news_category_test.dart` | Category list and the order of tabs after picking interests |
| `test/services/news_api_service_test.dart` | Good answer → articles, `[Removed]` news hidden, correct URL + API key header, errors: 401, 429, server message, bad JSON, no internet |
| `test/utils/source_style_test.dart` | Short source names (`WSJ`, `BBC`, `Axios`, `PS`), same source → same color |
| `test/utils/search_suggestions_test.dart` | Live search: order (recent → topics → title words), no duplicates, limit, match inside titles |
| `test/utils/date_helper_test.dart` | `formatDate` and `timeAgo` ("just now", "5 min ago", "1 day ago", date after 7 days) |

## 📱 Manual Test Plan

Test on a **real Android phone** in **release mode** (the same as the APK):

```bash
flutter run --release
```

> [!WARNING]
> **Why release mode?** A plugin bug only showed up in release mode (saved data was lost). See [LEARNING_LOG.md](LEARNING_LOG.md).

### 👋 A. First start and welcome screens

| # | Do this | Expected |
|---|---|---|
| A1 | Open the app (fresh install) | Red icon, then the **Welcome** screen |
| A2 | Tap **Get Started** | "Choose interests" screen |
| A3 | Pick 2–3 topics | Button shows **Continue (N selected)** |
| A4 | Tap **Continue** | Home opens. Picked topics are the first tabs after General |
| A5 | Close the app fully → open again | Home opens (no welcome screens) |
| A6 | Settings → **Show welcome screens again** → **Skip** | Welcome opens, Skip goes to Home |
| A7 | Bottom bar | 5 tabs: Home, Explore, Search, Saved, Settings |

### 🏠 B. Home

| # | Do this | Expected |
|---|---|---|
| B1 | Wait on the top banner | Moves every 5 seconds, endless, pieces of next/previous cards show |
| B2 | Hold the banner | It stops. Let go → moves again after 5 seconds |
| B3 | Scroll Latest News | Smooth. Titles max 2 lines. No-image stories (colored "WSJ" boxes) at the end of each page |
| B4 | Long source name | `The Wall Street Jo… • 1 day ago` (time always shows) |
| B5 | Pull down | Refreshes |
| B6 | Tap category tabs | News changes. Sri Lanka shows an "updated daily" note |

### 📜 C. Load more (pagination)

| # | Do this | Expected |
|---|---|---|
| C1 | Scroll to the end of Latest News | Small spinner, then more stories. Old rows don't move |
| C2 | Keep scrolling to the end | "You're all caught up" |
| C3 | Turn off internet, scroll to the end | "Couldn't load more. Tap to try again." |
| C4 | Turn on internet, tap it | More stories load |
| C5 | Search a word, scroll to the end | Load more also works in Search |

### 📰 D. Details, article and share

| # | Do this | Expected |
|---|---|---|
| D1 | Open a story | Big image, ← 🔖 📤, red category badge, source avatar, time |
| D2 | Scroll down | Image shrinks, buttons stay. Related News at the bottom |
| D3 | Tap a related story → Back | Back goes to the list |
| D4 | Tap 📤 | Phone share menu with title + link |
| D5 | Read full article | Website opens inside the app. 🔄 reload, 🌐 open in browser, ✖ close |

### 🔖 E. Bookmarks and Saved

| # | Do this | Expected |
|---|---|---|
| E1 | Tap 🔖 on a story | Red + "Saved to bookmarks" |
| E2 | Tap again → UNDO | Removed, then back in the same place |
| E3 | Saved → ⋮ → Clear all | Asks first. Then the empty view |
| E4 | Close the app fully → open again | Saved stories are still there |

### 🧭 F. Explore

| # | Do this | Expected |
|---|---|---|
| F1 | Tap a filter chip (e.g. Business) | Only Top Stories change, not Home |
| F2 | Tap a category box | Home opens on that category |
| F3 | Tap a `#topic` | Search opens with results |

### 🔍 G. Search

| # | Do this | Expected |
|---|---|---|
| G1 | Type "cri" | Live suggestions, guess part has a blue background |
| G2 | Tap ↖ | Word goes into the box |
| G3 | Press Search | Results with "Search Results (N)" |
| G4 | Search "zzqqxx" | "No results" view |
| G5 | Swipe a recent search | Removed |

### ⚙️ H. Settings and dark mode

| # | Do this | Expected |
|---|---|---|
| H1 | Light / Dark / System | Theme changes at once on all screens |
| H2 | Choose Light → close app → open | Still Light |
| H3 | My news interests → change → Save | Home tabs change order |
| H4 | About | Version from the app, licenses |
| H5 | GitHub / YouTube / NewsAPI rows | Open the right pages |
| H6 | Clear search history / cached news | Asks first, then clears |

### 📴 I. Offline

| # | Do this | Expected |
|---|---|---|
| I1 | Airplane mode → open the app | Saved news + "You are offline" bar |
| I2 | Open a category never opened | Error + Try again |
| I3 | Type in Search | Suggestions still work |
| I4 | Airplane mode off → Try again | News loads |

### ↩️ J. Back button and edge cases

| # | Do this | Expected |
|---|---|---|
| J1 | Back on any tab except Home | Goes to Home |
| J2 | Back on Home | App closes |
| J3 | Bigger phone font size | No overflow stripes |
| J4 | Tap tabs / 🔖 very fast | No crash |

### ✅ K. Code checks

| # | Run | Expected |
|---|---|---|
| K1 | `flutter analyze` | No issues found |
| K2 | `flutter test` | All tests passed |
| K3 | `git status` | `api_keys.dart` is not listed |