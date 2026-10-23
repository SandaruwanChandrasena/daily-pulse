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

**46 tests in 6 files.** Each test gives the code a small input and checks the answer.

| Test file | What it tests | Tests |
|---|---|---|
| `test/models/article_test.dart` | Turning NewsAPI JSON into an `Article` and back | 5 |
| `test/models/news_category_test.dart` | Category list and tab order after picking interests | 4 |
| `test/services/news_api_service_test.dart` | Calls to NewsAPI (with a fake server), pages and errors | 14 |
| `test/utils/source_style_test.dart` | Short source names and colors for the no-image boxes | 7 |
| `test/utils/search_suggestions_test.dart` | Live search suggestions and "In loaded news" matches | 10 |
| `test/utils/date_helper_test.dart` | Dates and "time ago" text | 6 |
| | **Total** | **46** |

#### 📰 1. `article_test.dart` — Article model (5 tests)

| Test | Input | Expected |
|---|---|---|
| Reads all fields | Full NewsAPI JSON: `"Rain in Colombo"`, BBC News, image, date | Every field is read correctly. Date = 19 Oct 2026, 06:30 UTC |
| Safe defaults | All fields `null`, date = `"not a date"` | Title `"No title"`, source `"Unknown source"`, empty text for the rest, date = now. **No crash** |
| Removes " - Source" from the title | `"Big news today - Axios"` from Axios | `"Big news today"` |
| Keeps a different ending | `"Big news today - Reuters"` from Axios | Title is not changed |
| `toJson` → `fromJson` | An article saved to JSON and read back | The copy is the same as the original (used for bookmarks and offline news) |

#### 🗂️ 2. `news_category_test.dart` — Categories and tab order (4 tests)

| Test | Input | Expected |
|---|---|---|
| Choosable list | `NewsCategory.choosable` | Every category **except General** (General can't be picked on the welcome screen) |
| No interests | `ordered([])` | Normal tab order |
| Picks move to the front | `ordered(['sports', 'srilanka'])` | **General → Sri Lanka → Sports** → the rest. No tab is lost |
| Unknown ids | `ordered(['cooking', 'science'])` | `cooking` is ignored. General → Science → the rest |

#### 🌐 3. `news_api_service_test.dart` — NewsAPI service (14 tests)

These tests use a **fake server** (`MockClient`). It returns a fixed answer, so no real request is sent.

**Top headlines**

| Test | Fake server answer | Expected |
|---|---|---|
| Good answer | 200 with 2 articles | 2 articles, first title `"One"`, `totalResults` = 2 |
| Hides removed news | Titles `One`, `[Removed]`, `Two` | Only `One` and `Two` |
| Right URL and key | Ask for `sports` | Path `/v2/top-headlines`, `category=sports`, `country=us`, `page=1`, `pageSize=25`, `X-Api-Key` header is sent |
| Next page | Ask for page 2 | `page=2` is sent, `totalResults` = 60 |
| No category | Ask with no category | No `category` in the URL |

**Search**

| Test | Fake server answer | Expected |
|---|---|---|
| Search word | Search `cricket`, title only, page 3 | Path `/v2/everything`, `q=cricket`, `searchIn=title`, `page=3` |

**Load more (`hasMorePages`)**

| Test | Input | Expected |
|---|---|---|
| More to load | Page 1 or 2 of 60 results | `true` |
| All loaded | Page 3 of 60 results, or page 1 of 10 | `false` |
| Free plan limit | 500 results: page 3 → page 4 | `true` → `false` (stops at **100 results**) |

**Errors**

| Test | Fake server answer | Expected message |
|---|---|---|
| 401 | Bad API key | Message about the **API key** |
| 429 | Too many requests | **"Too many requests"** (daily limit) |
| Other errors | 500 with `"Server is sleeping"` | Shows NewsAPI's own message |
| Bad JSON | 200 with HTML, not JSON | **"bad data"** message |
| No internet | Connection fails | **"No internet"**, and `isNoInternet = true` (the app then shows offline news) |

#### 🖼️ 4. `source_style_test.dart` — No-image boxes (7 tests)

| Test | Input | Expected |
|---|---|---|
| Initials, skip small words | `The Wall Street Journal` | `WSJ` |
| Short CAPITAL word | `BBC News` | `BBC` |
| Single word | `Axios` | `Axios` |
| Two-word name | `Page Six` | `PS` |
| Unknown or empty | `Unknown source`, `""` | `""` (empty) |
| Same color | `Reuters` twice | Same color both times |
| Different colors | `CNN` and `Bloomberg` | Different colors |

#### 💡 5. `search_suggestions_test.dart` — Live search (10 tests)

**`buildSuggestions` (the list under the search box)**

| Test | Input | Expected |
|---|---|---|
| Empty text | Only spaces | No suggestions |
| Order | Type `cri`: recent `Cricket world cup`, topic `Cricket` | Recent first, then topic |
| No duplicates | `Cricket`, `cricket`, `CRICKET` | Only 1 (the recent one). Upper/lower case is ignored |
| Not the same word | Type `cricket`, topic `Cricket` | Nothing (no point suggesting what is already typed) |
| Later word | Type `cup` | Finds `Cricket world cup` |
| Words from titles | Type `cri`: 2 titles with "cricket", 1 with "crime" | `Cricket` first (used more), then `Crime` |
| Limit | 8 matching topics | Only **6** suggestions |

**`findInTitles` (the "In loaded news" part)**

| Test | Input | Expected |
|---|---|---|
| At least 2 letters | Type `a` | Nothing |
| Any case | Type `ai` | `AI helps doctors`, `Rain in Colombo`, `New AI phone` |
| Limit | Type `ai`, limit 1 | Only 1 result |

#### 🕒 6. `date_helper_test.dart` — Dates (6 tests)

| Test | Input | Expected |
|---|---|---|
| `formatDate` | 18 Oct 2026, 5 Jan 2026 | `18 Oct 2026`, `5 Jan 2026` |
| Just now | 20 seconds ago | `just now` |
| Minutes | 5 minutes ago | `5 min ago` |
| Hours | 1 hour, 3 hours ago | `1 hour ago`, `3 hours ago` |
| Days | 1 day, 3 days ago | `1 day ago`, `3 days ago` |
| Old news | 10 days ago | The date (like `12 Oct 2026`) |

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