# Flutter Gradle Migration Guide: Groovy to Kotlin DSL

## Migration Steps for Older Flutter Projects

### Step 1: Backup Your Project
```bash
# Create a backup before migration
cp -r your_project your_project_backup
```

### Step 2: Update Flutter to Latest Version
```bash
flutter upgrade
flutter clean
```

### Step 3: File Renaming
Rename these files in your `android` folder:
- `build.gradle` → `build.gradle.kts`
- `settings.gradle` → `settings.gradle.kts`
- `app/build.gradle` → `app/build.gradle.kts`

### Step 4: Convert Root build.gradle to build.gradle.kts

**OLD (build.gradle):**
```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

**NEW (build.gradle.kts):**
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
```

### Step 5: Convert settings.gradle to settings.gradle.kts

**OLD (settings.gradle):**
```groovy
include ':app'

def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
def properties = new Properties()

assert localPropertiesFile.exists()
localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }

def flutterSdkPath = properties.getProperty("flutter.sdk")
assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"
```

**NEW (settings.gradle.kts):**
```kotlin
pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
```

### Step 6: Convert app/build.gradle to app/build.gradle.kts

**OLD (app/build.gradle):**
```groovy
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.example.your_app"
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```

**NEW (app/build.gradle.kts):**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.your_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.your_app"
        minSdk = flutter.minSdkVersion
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
```

### Step 7: Update Gradle Wrapper (if needed)

Check your `gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.12-all.zip
```

### Step 8: Common Syntax Conversions

| Groovy | Kotlin DSL |
|--------|------------|
| `apply plugin: 'com.android.application'` | `id("com.android.application")` |
| `compileSdkVersion 34` | `compileSdk = 34` |
| `minSdkVersion 21` | `minSdk = 21` |
| `targetSdkVersion 34` | `targetSdk = 34` |
| `versionCode 1` | `versionCode = 1` |
| `implementation 'androidx.core:core:1.8.0'` | `implementation("androidx.core:core:1.8.0")` |
| `signingConfig signingConfigs.debug` | `signingConfig = signingConfigs.getByName("debug")` |

### Step 9: Test Migration

After migration:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### Step 10: Common Issues and Solutions

**Issue: Build fails with "Unresolved reference"**
Solution: Ensure all property assignments use `=` operator

**Issue: Plugin application errors**
Solution: Check plugin block syntax and versions

**Issue: Dependencies not found**
Solution: Convert all dependency declarations to function call syntax

## Benefits After Migration

✅ **Better IDE Support**: Full autocomplete and error detection
✅ **Type Safety**: Compile-time error checking
✅ **Refactoring**: Safe refactoring across build files
✅ **Future-Proof**: Aligned with latest Android/Flutter practices
✅ **Consistency**: If using Kotlin for app development

## Need Help?

If you encounter issues during migration:
1. Check the Flutter documentation
2. Compare with a fresh Flutter project
3. Verify Gradle and plugin versions
4. Clean and rebuild the project
