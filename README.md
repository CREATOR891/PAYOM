# PAYOM

PAYOM is a Flutter Android messenger project with a blue dark interface.

## Configure Supabase for GitHub Actions

In GitHub, open **Settings → Secrets and variables → Actions** and add:

- `SUPABASE_URL`: the Project URL from Supabase Project Settings → API.
- `SUPABASE_PUBLISHABLE_KEY`: the project's publishable key (or legacy anon public key).

Never add a database password, Supabase service_role/secret key, SMS provider token, or other server secret to Flutter code or GitHub source files.

The app intentionally shows a configuration screen when these two public client settings are missing. Add the repository Actions secrets and run **Actions → Build PAYOM Android APK → Run workflow** again.

## Current implementation

- Supabase email/password sign-up and sign-in.
- Persistent Supabase auth session.
- Sign-out.
- Initial navigation shell for Chats, Status, Calls, and Settings.

The Chats, Status, and Calls pages are UI placeholders at this stage. Messaging, media, push notifications, group/channel permissions, and reviewed end-to-end encryption are not yet implemented. Do not use this build as a production messenger.
