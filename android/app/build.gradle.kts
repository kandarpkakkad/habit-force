import java.util.Properties

// Release signing lives in android/key.properties, which is deliberately not in
// version control. Without it a release build falls back to the debug key, so
// the build prints a warning rather than silently producing an unshippable APK.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.habitforce.habit_force"
    compileSdk = 36        // Android 16
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.habitforce.habit_force"
        manifestPlaceholders["appLabel"] = "Habit Force"
        // Android 16 and above only (D5): every API the native half uses is
        // platform, so there is no androidx.core and no compat branch.
        minSdk = 36
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // The debug key is named, not left to the Android plugin to find. On
        // a CI runner its default lookup finds nothing and mints a random key
        // per build — and an APK signed by a different key than the one on
        // the phone cannot be installed over it, only after an uninstall that
        // wipes every habit (D2: there is no backup to restore from).
        val projectDebugKey = rootProject.file("debug.keystore")
        if (projectDebugKey.exists()) {
            getByName("debug") {
                storeFile = projectDebugKey
                // Not secrets: these are the values every Android debug
                // keystore in the world uses.
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }

        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        debug {
            // A separate app, not the same one in a different mood: debug and
            // release install side by side with separate data, so trying a
            // debug build never touches the real habits.
            applicationIdSuffix = ".debug"
            manifestPlaceholders["appLabel"] = "Habit Force debug"
        }

        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "WARNING: android/key.properties is missing — signing this " +
                    "release with the DEBUG key. The result is not distributable."
                )
                signingConfigs.getByName("debug")
            }
        }
    }

    testOptions {
        // Boundaries and the block decision are pure Kotlin over java.time;
        // nothing Android is touched, and nothing should be faked silently.
        unitTests.isReturnDefaultValues = false
    }
}

flutter {
    source = "../.."
}

dependencies {
    testImplementation("junit:junit:4.13.2")
}
