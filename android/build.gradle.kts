buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ حل مشكلة: Extension with name 'flutter' does not exist (android_file_picker)
// بعض الحزم تستخدم flutter.xxx داخل مكتبتها، وهذا الـ extension لا يوجد إلا في :app
open class FlutterShim {
    val compileSdkVersion = 36
    val minSdkVersion = 24
    val targetSdkVersion = 36
    val ndkVersion = "27.0.12077973"
}

subprojects {
    if (name != "app" && extensions.findByName("flutter") == null) {
        extensions.create<FlutterShim>("flutter")
    }
}

// ✅ إعادة توجيه مخرجات البناء إلى مجلد build الخاص بـ Flutter
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}