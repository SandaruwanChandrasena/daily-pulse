# 📝 Daily Pulse — Learning Log

I built Daily Pulse to learn Flutter.
I came from **JavaScript**, and this was my first real Flutter app.

This log lists the problems I hit, **why** they happened, **how** I fixed them, and what I learned.

---

## ⭐ Top 3 Lessons

1. **Always test the release build.** My app saved nothing in release mode, but worked perfectly in debug. (See [#1](#1-nothing-was-saved-in-the-release-build).)
2. **A `try/catch` that only prints can hide a real bug.** It kept the app alive, but it also hid the error from me.
3. **Read the error message, slowly.** The file path and the first line usually tell you exactly where the problem is.

---

## 1️⃣ Build & Release

### #1 Nothing was saved in the release build

- **What happened:** In `flutter run --release`, my theme, bookmarks, search history and offline news were **not saved**. After restarting the app, everything was gone. In debug mode it worked fine.
- **Why:** `shared_preferences_android` 2.5.x has a bug with **R8** (the tool that shrinks release builds). R8 renamed some classes, so the plugin crashed with a `NoSuchMethodError`. My services had `try/catch` blocks that only printed the error, so the app looked fine but saved nothing.
- **How I found it:** I ran `flutter logs` while using the release app and saw the error.
- **Fix:** I pinned the package below the broken version in `pubspec.yaml`:
  ```yaml
  shared_preferences_android: ">=2.4.28 <2.5.0"
  ```
- **Lesson:** Debug and release builds are **not the same**. Test the release build before you ship. Links: [flutter#194649](https://github.com/flutter/flutter/issues/194649), [packages#13311](https://github.com/flutter/packages/pull/13311).

### #2 Kotlin "Could not close incremental caches"

- **What happened:** The Android build failed with a Kotlin cache error.
- **Why:** My project is on the **D:** drive, but the Flutter pub cache is on **C:**. Kotlin's incremental build has trouble with paths on different drives on Windows.
- **Fix:** Added `kotlin.incremental=false` to `android/gradle.properties`.
- **Lesson:** Some errors come from the **computer setup**, not the code. Search the exact error text.

### #3 The app felt slow and laggy

- **What happened:** Scrolling was not smooth.
- **Why:** Two things: I was testing in **debug mode** (debug is always slower), and news images were decoded at **full size** (some are 2000+ px wide) for small thumbnails.
- **Fix:** Tested in `--profile` / `--release` mode, and used `memCacheWidth` in `CachedNetworkImage` so images are decoded at the size they are shown.
- **Lesson:** Never judge speed in debug mode. Big images use a lot of memory.

### #4 Hot reload "didn't work"

- **What happened:** I saved a file and nothing changed on the phone.
- **Why:** I was running `flutter run --release`. Hot reload only works in **debug** mode.
- **Fix:** Use `flutter run` (debug) for UI tweaks. In release, stop (`q`) and run again.
- **Lesson:** Know which mode you are running.

---

## 2️⃣ Layout & UI

### #5 "Vertical viewport was given unbounded height"

- **What happened:** The screen went red with this error.
- **Why:** I put a `ListView` inside a `Column`. A `Column` gives its children **unlimited height**, but a `ListView` needs a fixed height to know how much to scroll.
- **Fix:** Wrapped the list in `Expanded`. For pages with many parts (banner + tabs + list), I used `CustomScrollView` with **slivers**.
- **Lesson:** Scrolling widgets need a size from their parent.

### #6 The selected category tab could not be scrolled into view

- **What happened:** When Explore opened a category that was off screen, the tab bar did not scroll to it.
- **Why:** `ListView.builder` only builds the items you can see. The hidden tab did not exist yet, so there was nothing to scroll to.
- **Fix:** Used a `Row` inside `SingleChildScrollView` (all tabs are built), and `Scrollable.ensureVisible` with a `GlobalKey` on the selected tab.
- **Lesson:** "Lazy" lists are fast, but you can't reach items that are not built.

### #7 Broken image boxes

- **What happened:** Some stories showed an ugly broken-image box.
- **Why:** NewsAPI sends **no image** for some sources (like the Wall Street Journal).
- **Fix:** A colored placeholder with the short source name (`WSJ`, `BBC`). The same source always gets the same color.
- **Lesson:** Never trust API data to be complete. Plan for empty fields.

### #8 Rows jumped when a new page loaded

- **What happened:** With "load more", rows I had already scrolled past suddenly moved.
- **Why:** I sorted the **whole list** to put stories without images at the end. A new page changed the order of old rows.
- **Fix:** Sort **each page on its own**, then add it to the end.
- **Lesson:** With pagination, items already on screen should never move.

### #9 Two "See All" buttons did different things

- **What happened:** One "See All" opened a category, another one expanded a list of chips.
- **Why:** I added them at different times without thinking about consistency.
- **Fix:** Removed the second one. Now "See All" always means the same thing.
- **Lesson:** Same label = same action. Users learn patterns.

### #10 Some text used the wrong font

- **What happened:** After I added Archivo and Inter, list rows in Settings, dialogs and snack bars still looked like the default font and size.
- **Why:** Widgets like `ListTile`, `AlertDialog` and `SnackBar` **replace** the text style instead of mixing it. A bare `TextStyle(fontSize: 15)` has no font, so it falls back to **Roboto**.
- **Fix:** In `app_theme.dart`, I built the text theme first, then set `listTileTheme`, `dialogTheme`, `snackBarTheme` and others with `text.bodyLarge?.copyWith(...)`, so they keep Inter / Archivo.
- **Lesson:** Put shared styles in the **theme**, not on every widget. One change fixes every page.

---

## 3️⃣ State & Async

### #11 An old search result could replace a new one

- **What happened:** If I searched "AI" then quickly "cricket", the "AI" results could appear last.
- **Why:** Two requests ran at the same time. The slower one finished last and overwrote the newer one (a **race condition**).
- **Fix:** When an answer comes back, check that its query is still the current query. If not, ignore it.
  ```dart
  if (query != _query) return;
  ```
- **Lesson:** Async answers don't arrive in order. This is the same problem as in JavaScript `fetch`.

### #12 Explore needed to switch the bottom tab

- **What happened:** Tapping a category on Explore had to open the Home tab, but only `MainShell` knew which tab was open.
- **Why:** The tab index was local state (`setState`) inside `MainShell`.
- **Fix:** Moved it into a `NavigationProvider` with an `AppTab` enum. Now any screen can call `goTo(AppTab.home)`.
- **Lesson:** If many widgets need some state, lift it into a provider.

---

## 4️⃣ NewsAPI

### #13 Switching categories used up my API requests

- **What happened:** The free plan allows only **100 requests per day**. Every tab tap was a new request.
- **Fix:** Each category's news is kept in memory and saved on the phone. It only reloads if it is older than **15 minutes**, or when I pull to refresh. This also gave me **offline mode** for free.
- **Lesson:** Cache data you already have. It is faster and saves money (or quota).

### #14 No Sri Lanka top headlines

- **What happened:** `country=lk` returned nothing.
- **Why:** NewsAPI top headlines do not support Sri Lanka.
- **Fix:** The Sri Lanka tab uses the **search** endpoint for `"Sri Lanka"` in titles, plus a note that stories are at least 1 day old (a free plan limit).
- **Lesson:** Read the API docs for limits **before** designing a feature. Be honest with the user about limits.

---

## 5️⃣ Git & Workflow

### #15 `.vscode/settings.json` was pushed to GitHub

- **Why:** The folder was not in `.gitignore`.
- **Fix:** Added it to `.gitignore`, then removed it from Git (not from my disk):
  ```bash
  git rm -r --cached .vscode
  ```
- **Lesson:** `.gitignore` does not remove files that Git already tracks.

### #16 The `macos/` folder came back

- **What happened:** I removed the desktop/web folders with `git rm`, but `macos/` showed up again.
- **Why:** Some ignored files stayed on disk, and Flutter regenerated a file in the folder.
- **Fix:** Deleted the folders fully from disk, then `git rm -r --cached macos`.
- **Lesson:** Check `git status` after cleanup.

### #17 "Your branch and 'main/main' have diverged"

- **What happened:** Git would not let me push.
- **Why:** I used `git commit --amend` on a commit I had **already pushed**. Amend makes a new commit, so my history no longer matched GitHub.
- **Fix:** `git reset --soft main/main`, then commit again.
- **Lesson:** Never amend a commit that is already pushed.

### #18 "PageTitle isn't a class"

- **What happened:** Many import errors at once.
- **Why:** I pasted the code of `main.dart` into `page_title.dart` by mistake.
- **Fix:** Read the **file path** in the error, opened that file, and pasted the right code.
- **Lesson:** The first error usually points to the real problem. The rest are side effects.

### #19 My API key must stay private

- **Fix:** The real key is in `lib/config/api_keys.dart`, which is in `.gitignore`. The repo has `api_keys.example.dart` as a template. I run `git status` before every commit to make sure the key file is not listed.
- **Lesson:** Never push secrets.

---

## 🎓 What I Learned (Overall)

### Flutter, coming from JavaScript

| JavaScript / React | Flutter / Dart |
|---|---|
| Components | Widgets (`StatelessWidget`, `StatefulWidget`) |
| `useState` | `setState` |
| Context / Redux | `provider` + `ChangeNotifier` |
| `fetch` + Promises | `http` + `Future` / `async` / `await` |
| `localStorage` | `shared_preferences` |
| CSS | `Theme`, `TextStyle`, padding widgets |
| Jest + mocks | `flutter_test` + `MockClient` |

### Skills

- **Layout:** `Row`, `Column`, `Expanded`, slivers, `CustomScrollView`, `PageView`.
- **State:** split code into screens → providers → services → models.
- **Networking:** JSON parsing with safe defaults, timeouts, friendly error messages.
- **Storage:** saving lists as JSON strings, offline cache.
- **Testing:** unit tests with a fake HTTP server, so tests need no internet.
- **Debugging:** `flutter logs`, profile/release modes, reading stack traces.
- **Design:** consistent spacing, one theme for light and dark, fonts in one place.

### If I did it again

- Test the **release build** from day one.
- Plan the **folder structure** at the start, not halfway.
- Write **tests** while writing the logic, not after.
