pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // ========== 新增：国内镜像（放前面优先命中）==========
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        // ==================================================

        google()
        mavenCentral()
        gradlePluginPortal()

        // ========== 新增：Flutter 插件仓库 ==========
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

// ========== 新增：依赖仓库集中管理（AGP 8+ 必须）==========
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    val storageUrl: String = System.getenv("FLUTTER_STORAGE_BASE_URL")
        ?: "https://storage.googleapis.com"
    repositories {
        // 国内镜像优先
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") } // 华为云兜底

        google()
        mavenCentral()

        // Flutter 依赖（engine + 插件 aar）
        maven("$storageUrl/download.flutter.io")
    }
}
// =======================================================

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
