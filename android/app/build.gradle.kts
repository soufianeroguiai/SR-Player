plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sr.player"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.sr.player"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        debug {
            storeFile file("${System.getProperty("user.home")}/.android/debug.keystore")
            storePassword "android"
            keyAlias "androiddebugkey"
            keyPassword "android"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

flutter {
    source = "../.."
}

// مهام إضافية: نسخ APK الناتج إلى المكان الذي يتوقعه Flutter
tasks.whenTaskAdded { task ->
    if (task.name.startsWith("merge") && task.name.endsWith("NativeLibs")) {
        task.doLast {
            copy {
                from "${buildDir}/outputs/apk/release/app-release.apk"
                into "${rootProject.buildDir}/../../../../build/app/outputs/flutter-apk/"
            }
        }
    }
}