# CardioPulse MD — source recovery from `app-release.apk`

**App:** CardioPulse MD Workstation · package `com.ecg.ecg_app` · Dart package `ecg_app` · v1.0.0
**Backend:** Supabase `https://xomswbnxqrxrjohjyhkm.supabase.co`

## What a release APK can and cannot give back

Flutter release builds compile Dart to native ARM code (`lib/*/libapp.so`). The original
`.dart` source is **not** in the APK and cannot be decompiled back to source.
This project is a **faithful rebuild**: real names and data recovered from the binary, with
the implementation rewritten to match.

| Recovered exactly | Rebuilt / guessed |
|---|---|
| All 52 file paths and folder layout (`recovered/original_file_list.txt`) | Widget trees and layout (rewritten to match the names) |
| Class names: pages, cubits, repositories, private widgets (`recovered/app_private_symbols.txt`) | Exact styling, spacing, animations |
| Every route path (`/home`, `/analysis-result`, `/help/faq` …) | Dependency **versions** (only package names survive) |
| Dependency list (supabase_flutter, go_router, flutter_bloc, get_it, pinput …) | `content` / `contact_info` table layout |
| Supabase URL and publishable key | RLS policies and column types |
| Tables: `profiles`, `patients`, `contact_messages`, `faq_votes`; RPC `faq_vote` | Onboarding images (not in the APK) |
| Nearly all English and Arabic UI text plus l10n keys | About 30 strings marked `// ~` in `app_localizations.dart` |
| Images, icon and splash (`assets/images/`) | |
| Theme font (Poppins), brand colours | |
| Mock AI results (`MockEcgAnalysisRepository`, its exact findings text) | |

## Get it running

Flutter SDK: `D:\flutter` (stable 3.50, Dart 3.14). `flutter analyze` passes with no issues and `flutter test` passes.
`android/` and `ios/` are generated, with application ID `com.ecg.ecg_app`, label "CardioPulse MD",
INTERNET permission and tel/mailto/https queries like the original. Launcher icons and splash
were generated from the original images.

Material and Cupertino are imported from the `material_ui` and `cupertino_ui` packages (the
Flutter 3.47+ split), the same packages the original APK used.

To build or run on a device you still need the Android SDK and JDK 17 (install Android Studio), then:

```bash
flutter doctor --android-licenses
flutter run
```

**Keep the same `applicationId` (`com.ecg.ecg_app`) and sign with your original keystore.**
Otherwise installed users can't update. If the keystore is lost too, you need a new
Play listing (or Play App Signing key-upgrade if you enrolled).

## Recover the real database schema (better than `supabase/schema.sql`)

The database is still live. Pull the true schema instead of using the reconstruction:

```bash
npx supabase login
npx supabase link --project-ref xomswbnxqrxrjohjyhkm
npx supabase db pull          # writes supabase/migrations/<ts>_remote_schema.sql
```

Then compare the queries in `lib/features/*/data/*_repository.dart` with it. Most likely
mismatches: `content` (privacy/terms/faq), `contact_info`, column types in `patients`.

## Getting closer to the original code (optional)

[blutter](https://github.com/worawit/blutter) disassembles `libapp.so` into per-function
pseudo-code with the exact strings, Supabase queries and calls each method made. It needs
Linux or WSL (or the Visual Studio C++ workload + Windows SDK + CMake + Ninja):

```bash
git clone https://github.com/worawit/blutter && cd blutter
python3 blutter.py path/to/apk/lib/arm64-v8a out_dir
```

Its `out_dir/asm/ecg_app/**` lets you check each rebuilt file against what the original did.

## Files

- `lib/` — rebuilt app (same 52-file structure as the original)
- `assets/images/` — original images from the APK
- `supabase/schema.sql` — reconstructed schema (guess; prefer `db pull`)
- `recovered/` — raw dumps: all strings, Arabic strings, private symbols, original file list
