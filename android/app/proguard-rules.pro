# Flutter Core
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Secure Storage & Crypto (Penting untuk Login)
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }

# Local Auth (Biometric)
-keep class io.flutter.plugins.localauth.** { *; }

# Image Cropper & Notifications
-keep class com.yalantis.ucrop.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Preserve Native Methods
-keepclasseswithmembernames class * {
    native <methods>;
}

-dontwarn androidx.**
-dontwarn com.google.android.play.**
