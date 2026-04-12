allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureNamespace = {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                val namespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                val getNamespaceMethod = android.javaClass.getMethod("getNamespace")
                val currentNamespace = getNamespaceMethod.invoke(android)
                if (currentNamespace == null) {
                    namespaceMethod.invoke(android, project.group.toString())
                }
            } catch (e: Exception) {
                // Ignore if method not found or other issues
            }
        }
    }

    if (project.state.executed) {
        configureNamespace()
    } else {
        afterEvaluate {
            configureNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
