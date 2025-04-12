# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Background Service & Reflection
-keep class com.example.bus.** { *; }
-keep class * extends android.app.Service

# Dart / JSON parsing
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepattributes Signature
-keepattributes *Annotation*

# Prevent removal of methods used via reflection
-keepclassmembers class ** {
    public *;
}

# HTTP (dio or http)
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Permissions
-keep class com.permission.** { *; }

# Geolocator & Location Services
-keep class com.baseflow.geolocator.** { *; }

# Prevent minification of SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Needed for foreground notification channel
-keep class androidx.core.app.NotificationCompat** { *; }
# Fix missing Play Core SplitCompat classes
-keep class com.google.android.play.** { *; }

# Required for Flutter deferred components and split install
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }