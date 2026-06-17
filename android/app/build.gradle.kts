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

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ✅ نسخ APK الناتج إلى المسار الذي يتوقعه Flutter تلقائياً
tasks.whenTaskAdded { task ->
    if (task.name == "assembleRelease") {
        task.doLast {
            val src = file("${buildDir}/outputs/apk/release/app-release.apk")
            val destDir = file("${rootProject.buildDir}/app/outputs/flutter-apk")
            val dest = file("${destDir}/app-release.apk")
            if (src.exists()) {
                destDir.mkdirs()
                src.copyTo(dest, overwrite = true)
                println("✅ تم نسخ APK إلى: ${dest.absolutePath}")
            } else {
                println("⚠️ لم يتم العثور على APK المصدر: ${src.absolutePath}")
            }
        }
    }
}