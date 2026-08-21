plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.wen.memora"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // applicationId 由各 flavor 覆盖，这里保留默认值仅为 Gradle 配置完整性
        applicationId = "com.wen.memora"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 三套环境与 APP_ENV 字符串保持一致
    // 命名：development / staging / production
    flavorDimensions += "environment"
    productFlavors {
        create("development") {
            dimension = "environment"
            applicationId = "com.wen.memora.dev"
            resValue("string", "app_name", "Memora Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationId = "com.wen.memora.staging"
            resValue("string", "app_name", "Memora Staging")
        }
        create("production") {
            dimension = "environment"
            applicationId = "com.wen.memora"
            resValue("string", "app_name", "Memora")
        }
    }

    buildTypes {
        release {
            // TODO(wen): 接入正式 keystore，避免长期使用 debug 签名
            // 目前临时使用 debug 签名，保证 flutter run --release 可用
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
