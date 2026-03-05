plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.monster_livescore"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.monster_livescore"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        // Configuration for signing release builds (you'll configure this later)
        // Required for uploading to Google Play
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Define flavor dimension for organizing flavors
    flavorDimensions += "app"

    // Define product flavors (dev, staging, prod)
    productFlavors {
        create("dev") {
            dimension = "app"
            // Unique package name so you can install all flavors on one device
            applicationIdSuffix = ".dev"
            // String resource that shows in launcher
            resValue("string", "app_name", "Monster Livescore Dev")
            // Can be read from native Android code if needed
            resValue("string", "api_base_url", "https://dev-api.example.com")
        }
        create("staging") {
            dimension = "app"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Monster Livescore Staging")
            resValue("string", "api_base_url", "https://staging-api.example.com")
        }
        create("prod") {
            dimension = "app"
            // No suffix for production - default package name
            resValue("string", "app_name", "Monster Livescore")
            resValue("string", "api_base_url", "https://api.example.com")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}
