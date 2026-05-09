plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.enruta_app"
    compileSdk = 36  // Fijar a 34 para mejor compatibilidad
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.enruta_app"
        minSdk = flutter.minSdkVersion  // Aumentado para mejor soporte de GPS en segundo plano
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Configuración adicional para GPS
        manifestPlaceholders["appAuthRedirectScheme"] = "enruta"
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

// Dependencias adicionales para GPS en segundo plano
dependencies {
    implementation("com.google.android.gms:play-services-location:21.0.1")
    implementation("androidx.work:work-runtime:2.8.1")
}