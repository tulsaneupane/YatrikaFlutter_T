plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tour_guide"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.tour_guide"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Rename produced APKs to include the desired app name.
// This registers a simple task that looks for APKs in common Flutter/Android output
// directories and renames them to start with `Yatrika-A smart trip planner-`.
tasks.register("renameApk") {
    doLast {
        val apkDirs = listOf(
            File(buildDir, "app/outputs/flutter-apk"),
            File(buildDir, "outputs/flutter-apk"),
            File(buildDir, "app/outputs/apk"),
            File(buildDir, "outputs/apk")
        )
        apkDirs.forEach { dir ->
            if (dir.exists()) {
                dir.listFiles { f -> f.extension == "apk" }?.forEach { file ->
                    val safeName = "Yatrika-A smart trip planner-${file.name}"
                    val dest = File(file.parentFile, safeName)
                    if (file.renameTo(dest)) {
                        println("Renamed ${file.name} -> ${dest.name}")
                    } else {
                        println("Failed to rename ${file.absolutePath} -> ${dest.absolutePath}")
                    }
                }
            }
        }
    }
}

// Run the rename after common assemble tasks so the final APK has the requested name.
listOf("assembleRelease", "assembleDebug").forEach { taskName ->
    tasks.matching { it.name == taskName }.configureEach {
        finalizedBy("renameApk")
    }
}
