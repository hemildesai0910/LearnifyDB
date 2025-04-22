# SQL Learning Platform with Supabase Authentication

This Flutter application provides SQL tutorials, interactive quizzes, and documentation. It uses Supabase for backend services including authentication.

## Authentication Features

- Email/Password authentication
- Google Sign-In
- GitHub Sign-In
- Password reset functionality
- User profiles

## Setup Instructions

### Prerequisites

- Flutter SDK (stable channel)
- A Supabase account
- Google Developer account (for Google Sign-In)
- GitHub Developer account (for GitHub Sign-In)

### Step 1: Clone the repository

```bash
git clone <repository-url>
cd sql-learning-app
```

### Step 2: Set up Supabase

1. Create a new project on [Supabase](https://supabase.com/).
2. Once your project is created, go to the SQL Editor in the Supabase dashboard.
3. Copy the entire content of the `supabase_setup.sql` file from this project.
4. Paste and run the SQL query in the SQL Editor. This will:
   - Create the required tables (profiles, user_progress, user_achievements)
   - Set up row-level security policies
   - Create functions and triggers for user management

### Step 3: Configure Authentication Providers

#### Email Provider
1. In your Supabase dashboard, navigate to Authentication > Providers > Email.
2. Ensure the Email provider is enabled.
3. Configure settings for email confirmation if desired.

#### Google Provider
1. Navigate to Authentication > Providers > Google.
2. Enable the Google provider.
3. Follow the instructions to set up Google OAuth credentials.
4. Add your app's redirect URL (typically: `io.supabase.sqlgame://login-callback/`).
5. Copy your Google client ID and client secret to Supabase.

#### GitHub Provider
1. Navigate to Authentication > Providers > GitHub.
2. Enable the GitHub provider.
3. Register a new OAuth application on [GitHub](https://github.com/settings/developers).
4. Set the Authorization callback URL to your Supabase redirect URL.
5. Copy your GitHub client ID and client secret to Supabase.

### Step 4: Environment Setup

1. Create a `.env` file in the root of your project.
2. Add the following variables with your Supabase details:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_REDIRECT_URL=io.supabase.sqlgame://login-callback/
```

### Step 5: Add Social Icons

1. Ensure you have Google and GitHub icons in the `assets/icons/` directory:
   - `google_icon.png`
   - `github_icon.png`

### Step 6: Update Android Configuration

For Android, update the `android/app/src/main/AndroidManifest.xml` file to include:

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="io.supabase.sqlgame"
        android:host="login-callback" />
</intent-filter>
```

### Step 7: Update iOS Configuration

For iOS, update the `ios/Runner/Info.plist` file to include:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.supabase.sqlgame</string>
        </array>
    </dict>
</array>
```

### Step 8: Run the app

```bash
flutter pub get
flutter run
```

## Troubleshooting

- If you encounter issues with social logins, check that redirect URLs match exactly.
- For Google authentication on Android, ensure you have configured the Google Services file.
- For email authentication, check Supabase logs to ensure emails are being sent correctly.
- If the database tables weren't created properly, manually run each part of the SQL script.

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)

## Features

- **Interactive SQL Lessons**: Learn SQL concepts with step-by-step tutorials
- **SQL Quiz**: Test your knowledge with quizzes on various SQL topics
- **AI SQL Bot**: Get assistance with SQL queries from an AI assistant
- **Documentation**: Access comprehensive SQL reference materials
- **AI Quiz Generator**: Create custom SQL quizzes with AI assistance
- **Certification**: Earn certificates to showcase your SQL skills

## UI Design

### New Dashboard UI

The new dashboard features a clean, modern design with:

```
+--------------------------------------------------+
|                                                  |
| SQL Learning                           🌙  👤    |
|                                                  |
| +----------------------------------------------+ |
| |                                              | |
| | Welcome back,                                | |
| | Learner                                      | |
| |                                              | |
| | Continue your SQL learning journey           | |
| |                                              | |
| +----------------------------------------------+ |
|                                                  |
| +----------------------------------------------+ |
| |                                              | |
| | 📊 Your Progress                       30%   | |
| |                                              | |
| | [===============------------]                | |
| |                                              | |
| | +-------+  +-------+  +-------+             | |
| | |Lessons|  |Quizzes|  |Badges |             | |
| | |  3/10 |  |  2/8  |  |  1/5  |             | |
| | +-------+  +-------+  +-------+             | |
| |                                              | |
| +----------------------------------------------+ |
|                                                  |
| Learning Path                                    |
|                                                  |
| +----------------+  +----------------+           |
| |                |  |                |           |
| | 📚             |  | 📝             |           |
| | SQL Learning   |  | SQL Quiz       |           |
| |                |  |                |           |
| | Learn SQL      |  | Test your SQL  |           |
| | fundamentals   |  | knowledge with |           |
| | with lessons   |  | quizzes        |           |
| |                |  |                |           |
| +----------------+  +----------------+           |
|                                                  |
| +----------------+  +----------------+           |
| |                |  |                |           |
| | 🤖             |  | 📄             |           |
| | AI SQL Bot     |  | Documentation  |           |
| |                |  |                |           |
| | Get help with  |  | Access SQL     |           |
| | SQL queries    |  | reference      |           |
| | from AI        |  | materials      |           |
| |                |  |                |           |
| +----------------+  +----------------+           |
|                                                  |
| +----------------+  +----------------+           |
| |                |  |                |           |
| | ✨             |  | 🏆             |           |
| | AI Generator   |  | Certification  |           |
| |                |  |                |           |
| | Create custom  |  | Earn SQL       |           |
| | SQL quizzes    |  | certificates   |           |
| | with AI        |  | for your skills|           |
| |                |  |                |           |
| +----------------+  +----------------+           |
|                                                  |
+--------------------------------------------------+
```

## Design Highlights

1. **Clean Interface**: Minimalist design with proper spacing and visual hierarchy
2. **Card-Based Layout**: Organized content in cards with consistent styling
3. **Visual Progress Tracking**: Clear progress indicators and statistics
4. **Modern Color Scheme**: Pleasant color palette with light/dark mode support
5. **Descriptive Cards**: Feature cards with icons and descriptions

## Getting Started

To run the application:

```bash
flutter run
```

## Dependencies

- Flutter SDK
- Dart
- Provider for state management
- Shared Preferences for local storage

## Technical Details

- Built with Flutter for cross-platform support
- State management with Provider
- Local storage using SharedPreferences and SQLite
- Integration with AI services for chatbot and quiz generation
- PDF generation for certificates

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Dependencies

- flutter: SDK
- cupertino_icons: ^1.0.5
- lottie: ^2.3.2
- http: ^1.1.0
- sqflite: ^2.2.8+4
- path: ^1.8.3
- provider: ^6.0.5
- shared_preferences: ^2.1.1
- flutter_svg: ^2.0.5
- path_provider: ^2.0.15
- url_launcher: ^6.1.11
- pdf: ^3.10.1
- flutter_quill: ^7.2.0 