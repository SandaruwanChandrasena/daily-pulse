# 🧪 Daily Pulse — Testing

This file explains how Daily Pulse is tested:

1. **Unit tests**: automatic tests for the logic. Run them with `flutter test`.
2. **Manual test plan**: a checklist to test the real app on a phone.

---

## 1. Unit tests

### How to run

```bash
flutter test
```

> You need `lib/config/api_keys.dart` first (copy `api_keys.example.dart`).
> The tests **never call the real NewsAPI**. They use a fake server (`MockClient`),
> so they need no internet and use none of the 100 daily requests.

### What is tested

| Test file | What it checks |
|---|---|
| `test/models/article_test.dart` | `fromJson` reads NewsAPI JSON, safe defaults for null fields, removes `" - Source"` from titles, `toJson` → `fromJson` gives the same article |
| `test/services/news_api_service_test.dart` | Good answer → articles, `[Removed]` news hidden, correct URL + API key header, errors: 401, 429, server message, bad JSON, no internet |
| `test/utils/source_style_test.dart` | Short source names (`WSJ`, `BBC`, `Axios`, `PS`), same source → same color |
| `test/utils/search_suggestions_test.dart` | Live search: order (recent → topics → title words), no duplicates, limit, match inside titles |
| `test/utils/date_helper_test.dart` | `formatDate` and `timeAgo` ("just now", "5 min ago", "1 day ago", date after 7 days) |

---

## 2. Manual test plan

Test on a **real Android phone** in **release mode** (the same as the APK):

```bash
flutter run --release
```

> Why release mode? A plugin bug only showed up in release mode
> (saved data was lost). See `LEARNING_LOG.md`.

### A. First start
| # | Do this | Expected |
|---|---|---|
| A1 | Open the app (fresh install) | Red icon, then Home loads with a spinner |
| A2 | Bottom bar | 5 tabs: Home, Explore, Search, Saved, Settings |

### B. Home
| # | Do this | Expected |
|---|---|---|
| B1 | Wait on the top banner | Moves every 5 seconds, endless, pieces of next/previous cards show |
| B2 | Hold the banner | It stops. Let go → moves again after 5 seconds |
| B3 | Scroll Latest News | Smooth. Titles max 2 lines. No-image stories (colored "WSJ" boxes) at the end |
| B4 | Long source name | `The Wall Street Jo… • 1 day ago` (time always shows) |
| B5 | Pull down | Refreshes |
| B6 | Tap category tabs | News changes. Sri Lanka shows an "updated daily" note |

### C. Details, article and share
| # | Do this | Expected |
|---|---|---|
| C1 | Open a story | Big image, ← 🔖 📤, red category badge, source avatar, time |
| C2 | Scroll down | Image shrinks, buttons stay. Related News at the bottom |
| C3 | Tap a related story → Back | Back goes to the list |
| C4 | Tap 📤 | Phone share menu with title + link |
| C5 | Read full article | Website opens inside the app. 🔄 reload, 🌐 open in browser, ✖ close |

### D. Bookmarks and Saved
| # | Do this | Expected |
|---|---|---|
| D1 | Tap 🔖 on a story | Red + "Saved to bookmarks" |
| D2 | Tap again → UNDO | Removed, then back in the same place |
| D3 | Saved → ⋮ → Clear all | Asks first. Then the empty view |
| D4 | Close the app fully → open again | Saved stories are still there |

### E. Explore
| # | Do this | Expected |
|---|---|---|
| E1 | Tap a filter chip (e.g. Business) | Only Top Stories change, not Home |
| E2 | Tap a category box | Home opens on that category |
| E3 | Tap a `#topic` | Search opens with results |

### F. Search
| # | Do this | Expected |
|---|---|---|
| F1 | Type "cri" | Live suggestions, guess part has a blue background |
| F2 | Tap ↖ | Word goes into the box |
| F3 | Press Search | Results with "Search Results (N)" |
| F4 | Search "zzqqxx" | "No results" view |
| F5 | Swipe a recent search | Removed |

### G. Settings and dark mode
| # | Do this | Expected |
|---|---|---|
| G1 | Light / Dark / System | Theme changes at once on all screens |
| G2 | Choose Light → close app → open | Still Light |
| G3 | About | Version from the app, licenses |
| G4 | GitHub / YouTube / NewsAPI rows | Open the right pages |
| G5 | Clear search history / cached news | Asks first, then clears |

### H. Offline
| # | Do this | Expected |
|---|---|---|
| H1 | Airplane mode → open the app | Saved news + "You are offline" bar |
| H2 | Open a category never opened | Error + Try again |
| H3 | Type in Search | Suggestions still work |
| H4 | Airplane mode off → Try again | News loads |

### I. Back button and edge cases
| # | Do this | Expected |
|---|---|---|
| I1 | Back on any tab except Home | Goes to Home |
| I2 | Back on Home | App closes |
| I3 | Bigger phone font size | No overflow stripes |
| I4 | Tap tabs / 🔖 very fast | No crash |

### J. Code checks
| # | Run | Expected |
|---|---|---|
| J1 | `flutter analyze` | No issues found |
| J2 | `flutter test` | All tests passed |
| J3 | `git status` | `api_keys.dart` is not listed |