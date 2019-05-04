# Flutter Product Manager

This is a sample Flutter application which tackles some of the most used concepts in app development:

- State Management
- Authentication
- Navigation
- REST communication
- Working with the camera
- Maps
- Animations
- Static code analysis

The app was created as part of [this udemy course](https://www.udemy.com/course/learn-flutter-dart-to-build-ios-android-apps/).

While UI and functionality follows requirements defined in the course, the code is modified in many parts to follow general best practices and style guidelines defined by the Flutter community that were omitted by the course author.


## Development environment setup

* [Install the Dart SDK](https://webdev.dartlang.org/tools/sdk#install) and [Flutter](https://flutter.io/docs/get-started/install)
* Install an IDE. You can't go wrong with [Visual Studio Code](https://code.visualstudio.com). If that doesn't tickle your fancy, [there are other options too](https://www.dartlang.org/tools#ides).
* Install the Dart and Flutter plugin for your IDE.

Once you have your tools setup, make sure to download all dependencies for the project by running `flutter packages get` inside the project root. You can read more about Flutter dependency management [here](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

In order to actually work with products, you will need to [create a new Firebase project](https://console.firebase.google.com/). 
After enabling email authentication and real-time database, you have to update the database URL and API key inside `lib\scoped_models\url_builder.dart`.
