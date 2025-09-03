# Flutter LINE Login Demo

A simple Flutter project demonstrating the basic implementation of LINE Login.

## 🔧 Summary

To integrate LINE Login, the following files were modified:

### [pubspec.yaml](pubspec.yaml)
* Adds the `flutter_line_sdk` package as a dependency to the project.

### [lib/main.dart](lib/main.dart)
* Contains all the application logic. It initializes the LINE SDK with a Channel ID, handles the `login()` and `logout()` API calls, and displays the user's profile information on the screen.

### [android/app/build.gradle.kts](android/app/build.gradle.kts)
*  Sets the minimum Android SDK version required by the LINE SDK (e.g., `minSdkVersion(24)`).

### [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
* Declares the specific `Activity` that the LINE SDK uses to present the login screen to the user.

### [ios/Runner/Info.plist](ios/Runner/Info.plist)
* Configures the custom URL scheme required for the LINE app to redirect back to this application after a successful login.
