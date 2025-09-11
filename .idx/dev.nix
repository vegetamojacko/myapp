{ pkgs, ... }:

let
  # Override the default Android SDK to include necessary components.
  # This makes the SDK available with platform-tools, build-tools, etc.
  android_sdk_package = (pkgs.flutter.build-environment.android-sdk.override {
    cmdline-tools = true;
    platform-tools = true;
    build-tools = true;
  });
in
{
  # Specify the packages needed for the environment.
  # Note: pkgs.dart is not needed as it's included with pkgs.flutter.
  packages = [
    pkgs.flutter,
    android_sdk_package # Add the configured Android SDK
  ];

  # Let Nix manage the IDE extensions.
  idx.extensions = [
    "dart-code.flutter",
    "dart-code.dart-code"
  ];

  # Set environment variables.
  env = {
    # CORRECTED: The path should point to the root of the package.
    ANDROID_HOME = "${android_sdk_package}";
  };

  # Configure previews for the workspace.
  idx.previews = {
    enable = true;
    previews = [
      # This web preview is correct.
      {
        id = "web";
        command = "flutter run -d web-server --web-port $PORT --web-hostname 0.0.0.0";
        manager = "web";
      }
      # REMOVED: The Android preview block was incorrect.
      # To run on Android, open the emulator from the side panel and
      # run `flutter run` from the terminal.
    ];
  };

  # Any commands that should be run when the workspace starts.
  idx.workspace.onStart = {
    # This command correctly accepts Android licenses automatically.
    "yes | ${android_sdk_package}/bin/sdkmanager --licenses" = {};
    # Optional: You can also run flutter doctor to check your setup on start.
    # "flutter doctor" = {};
  };
}