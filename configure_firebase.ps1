# Configure Firebase for urbanstay project
Write-Host "Installing dependencies..."
flutter pub add firebase_core
flutter pub get

Write-Host "Activating flutterfire CLI..."
dart pub global activate flutterfire_cli

Write-Host "Configuring Firebase..."
dart pub global run flutterfire_cli:configure --project=urbanstay-8f9e7 --platforms=android,ios,macos,web,windows

Write-Host "Done! Please check lib/firebase_options.dart"
