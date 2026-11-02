allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional local cache location; keep one canonical path for Flutter artifacts.
val externalBuildDir = providers.environmentVariable("BALB_BUILD_DIR").orNull
val newBuildDir: Directory = if (externalBuildDir != null) {
    layout.dir(provider { file(externalBuildDir) }).get()
} else {
    rootProject.layout.buildDirectory.dir("../../build").get()
}
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
