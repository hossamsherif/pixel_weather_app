PixelWeather POC — Product Requirements Document (v0.1)
1) Summary
PixelWeather is a mobile weather app built in Flutter for iOS + Android, intended as an internal demo to experience a full build lifecycle from PM + Designer + Engineer perspectives.
It provides:
Current conditions


Hourly forecast


5-day forecast


City search


GPS auto-detect


Weather icons


Favorites


Dark mode


Cache last result for offline/poor network


Design direction: minimal UI with a pixel-art look (pixel font + pixel icons + simple retro layout), with room to polish later.

2) Goals
Product goals
Demonstrate a complete app build via AI agent: requirements → design → implementation → testing.


Provide a satisfying, usable “weather glance” experience for internal demo.


Show thoughtful UX behaviors (loading/error/offline/favorites).


Engineering goals
Clean, maintainable Flutter architecture suitable for iterating.


Clear separation: UI ↔ state ↔ data layer.


Deterministic caching behavior (show last known data when offline).



3) Non-goals (Out of scope for v1)
Radar maps


Home screen widgets (explicitly “later”)


AI chatbot


Complex accounts/authentication



4) Personas
Demo Viewer (Internal Stakeholder): wants to see it “just work” and look charming.


Builder (You/Team): wants to inspect how PRD drives design + code decisions.


QA Mindset: wants predictable behaviors across edge cases.



5) User stories
As a user, I can see current weather for my location.


As a user, I can search a city and view its weather.


As a user, I can save favorites and switch quickly.


As a user, I can see hourly and 5-day forecast.


As a user, I can use dark mode comfortably.


As a user, if my network is bad, I still see cached last results.



6) Core experience & screens
Navigation model
Bottom navigation (3 tabs):
Now


Forecast


Favorites


Plus: Search as an action (top bar icon or dedicated field on Now).
Screen details
A) Now (Current)
Location name (city, country)


Current temperature + feels-like


Condition (e.g., Clear, Rain)


Pixel-art icon


Key stats row: humidity, wind, precipitation chance (if available), sunrise/sunset (optional)


“Last updated” timestamp


Pull-to-refresh


B) Forecast
Hourly (next 12–24 hours): horizontal list


Daily (5 days): vertical list cards/rows


Tap a day opens a simple detail view (optional in v1; can be inline expansion)


C) Favorites
List of saved locations


Reorder (optional v1.1)


Swipe to delete


Tap to load weather for that favorite


D) Search (modal/page)
Text input for city


Results list (disambiguation if multiple cities)


Select result → load weather


“Add to favorites” toggle/CTA



7) Functional requirements (v1)
Location
GPS auto-detect via OS permission


If permission denied: app still works via search


Location used to fetch weather should be represented as:


lat, lon, displayName, source (gps/search/favorite)


Weather data
Must display:
Current temp, feels-like


Condition text + icon


Hourly forecast (temp + icon + time)


Daily forecast (high/low + icon + weekday)


Units: default to metric (assumption; see open questions)


Favorites
Add/remove favorite locations


Persist favorites locally


Favorites list loads instantly (local storage)


Caching (must-have)
Cache last successful weather response per location with timestamp


If network fails, show:


cached data (if available) + “Offline / Showing last updated …”


otherwise show an error empty state with retry + search prompt


Dark mode
Support system theme (auto) + internal theming for both light/dark


Pixel palette should remain readable in dark mode



8) Data/API requirements (OpenWeather)
API approach
Use OpenWeather endpoints to support:
Geocoding for search (city → lat/lon)


Weather + forecast for lat/lon


Implementation rule:
Prefer One Call if your key supports it; otherwise combine Current Weather + Forecast endpoints.


The agent should implement the simplest combination that yields required UI fields.


API key handling (testing key)
API key stored in a non-committed config:


.env (flutter_dotenv) OR build-time --dart-define=OPENWEATHER_KEY=...


App must run locally without code changes once the key is provided.



9) UX requirements (pixel-art style, minimal v1)
Visual style (v1)
Pixel font for headings (optional fallback)


Pixel icons for conditions (sun, clouds, rain, thunder, snow, fog)


Chunky cards/containers with 1–2px “pixel border”


Simple micro-animations:


loading shimmer replaced by a pixel “…” indicator (optional)


subtle icon bobbing (optional)


States
Loading: skeleton or pixel loader


Error (no cache): friendly message + retry + search CTA


Offline (with cache): show cached + offline badge


Permission denied: show “Enable location” CTA + “Search instead”



10) Non-functional requirements
Performance: initial screen interactive < 2s on mid device (best effort)


Reliability: graceful handling of API errors, rate limiting, timeouts


Maintainability: clear folder structure + typed models + repository pattern


Testability:


unit tests for parsing + caching + repository


widget test for at least one main screen rendering with stubbed state



11) Technical design (for the AI coding agent)
Recommended architecture
State management: Riverpod (or Bloc; choose one and stick to it)


Layers:


data/ (DTOs, API client, local cache)


domain/ (entities, repository interface, use cases)


presentation/ (screens, widgets, state/controllers)


Local storage
Favorites: shared_preferences (simple list of serialized favorites)


Cached weather payloads: hive (recommended) or shared_preferences (ok for POC)


Key by locationId (e.g., "lat,lon" rounded to 4 decimals)


Networking
dio or http with:


timeouts


simple retry on transient failures (max 1 retry)


logging interceptor in debug


Mapping conditions → pixel icons
Map OpenWeather weather codes (or main condition) to a small icon set:


Clear → sun


Clouds → cloud


Rain/Drizzle → rain


Thunderstorm → thunder


Snow → snow


Mist/Fog/Haze → fog


Fallback icon: “unknown”



12) Acceptance criteria (definition of done)
App launches on iOS/Android simulator/device.


With location permission granted:


shows current weather within 1 refresh cycle


shows hourly + 5-day forecast


With permission denied:


app remains usable via search


Search:


searching “Cairo” returns results; selecting one loads weather


Favorites:


add at least 3 locations; persists across relaunch


Offline:


after one successful fetch, enabling airplane mode still shows cached weather with timestamp


Dark mode:


readable UI; no clipped text; icons visible


Basic tests pass (unit + 1 widget test)



13) Delivery plan (POC milestones)
M1 — App skeleton: navigation, theming, empty states


M2 — OpenWeather integration: geocoding + fetch now/forecast


M3 — State management + models: typed parsing, error handling


M4 — Favorites + caching: persistence, offline behavior


M5 — Pixel UI pass: icons, font, borders, polish pass


M6 — Tests + demo script: happy path + offline + permission denied



14) Risks / pitfalls
OpenWeather plan limitations (One Call access / fields availability)


Rate limits (testing key); must implement friendly retry/backoff messaging


Pixel art asset scope creep (keep icon set small for v1)



15) Open questions (won’t block build; agent can assume defaults)
Units: allow  toggle between metric and imperial (metric default) 


Language: English and Arabic  (English default)


Hourly range: show next 12 or 24 hours? (assume 24)


Daily range: exactly 5 days? (assume 5)


Favorites limit: unlimited? (assume unlimited)


Refresh policy: manual only vs auto refresh on app open? (assume both: refresh on open + pull-to-refresh)


