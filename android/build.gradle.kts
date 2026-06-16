allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔥 إجبار كل dependencies تستخدم Kotlin 2.0.0 فقط
configurations.all {
    resolutionStrategy {
        force("org.jetbrains.kotlin:kotlin-stdlib:2.0.0")
        force("org.jetbrains.kotlin:kotlin-stdlib-jdk7:2.0.0")
        force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.0.0")

        eachDependency {
            if (requested.group == "org.jetbrains.kotlin") {
                useVersion("2.0.0")
            }
        }
    }
}

// build clean task
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}