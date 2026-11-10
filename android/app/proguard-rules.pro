# Preserve Dart JNI Flutter Plugin classes from being stripped by R8/JNI reflection
-keep class com.github.dart_lang.jni_flutter.** { *; }
-keep class com.github.dart_lang.jni.** { *; }
-keepclassmembers class com.github.dart_lang.jni_flutter.** { *; }

# Preserve Google ML Kit & Flutter embedding plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }