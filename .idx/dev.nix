{ pkgs, ... }:

let
  # Override the default Android SDK to include necessary components
  android-sdk = (pkgs.android-sdk.override {
    cmdline-tools = true;
    platforms = ["android-33"];
    build-tools = ["33.0.2"];
    platform-tools = true;
  });
in
{
  # Specify the packages needed for the environment
  packages = [
    pkgs.flutter
    pkgs.dart
    android-sdk # Add the configured Android SDK
  ];

  # Let Nix manage the IDE extensions
  idx.extensions = [
    "dart-code.flutter"
    "dart-code.dart-code"
  ];

  # Set environment variables
  env = {
    # Set the path to the Android SDK
    ANDROID_HOME = "${android-sdk}/share/android-sdk";
  };

  # Start a web server on port 8080 and run the Flutter app
  idx.previews = {
    enable = true;
    previews = [{
      id = "web";
      command = "flutter run -d web-server --web-port $PORT --web-hostname 0.0.0.0";
      manager = "web";
    }];
  };

  # Any commands that should be run when the workspace starts.
  idx.workspace.onStart = {
     # Accept Android licenses automatically
     "yes | ${android-sdk}/bin/sdkmanager --licenses" = {};
  };
}