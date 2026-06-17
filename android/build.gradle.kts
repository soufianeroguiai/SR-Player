buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.20")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
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
    delete(rootProject.buildDir)
}