# 🏛️ Proyecto Evaluación Sísmica - Frontend

Aplicación móvil multiplataforma desarrollada en **Flutter** para el sistema de gestión de inspecciones sísmicas. Este frontend permite a los inspectores registrar datos técnicos en campo, gestionar edificios evaluados y generar reportes profesionales de vulnerabilidad.

---

<img width="1901" height="942" alt="image" src="https://github.com/user-attachments/assets/c45d6e15-02ea-48f6-b996-e38afc80e3d6" />


## 🏗️ Arquitectura

El proyecto sigue una arquitectura limpia (Clean Architecture) con separación de responsabilidades, facilitando la escalabilidad y el mantenimiento:



* **lib/core/**: Contiene la lógica central y configuraciones globales.
    * **config/**: Configuración de la base de datos y llaves de API (`database_config.dart`).
    * **constants/**: Endpoints y rutas de la API (`database_endpoints.dart`).
    * **services/**: Lógica de comunicación con APIs (`auth_service`, `building_service`, `inspection_service`).
    * **theme/**: Definición de colores y estilos globales (`app_theme.dart`).
* **lib/data/models/**: Definición de modelos de datos y mapeo de respuestas JSON (`auth_response`, `building_response`).
* **lib/ui/**: Capa de presentación (UI).
    * **screens/**: Interfaces de usuario organizadas por flujo (Registro de edificios, Login, Home).
    * **widgets/**: Componentes reutilizables como botones y campos de texto (`fields.dart`).

---

## 🚀 Características

* **Registro Multietapa:** Formulario especializado dividido en 5 fases para una recolección de datos técnicos organizada.
* **📍 Geolocalización:** Obtención automática de coordenadas GPS y direcciones exactas mediante `geolocator`.
* **📸 Gestión de Imágenes:** Captura y procesamiento de evidencias fotográficas con `image_picker`.
* **📄 Reportes Técnicos:** Generación de documentos PDF y gestión de impresión desde la App.
* **🔐 Autenticación Robusta:** Integración con **Supabase Auth** para manejo de sesiones seguras.
* **🎨 UI/UX Moderna:** Interfaz diseñada con `google_fonts` y soporte para validación de teléfonos.

---

## 🛠️ Prerrequisitos

* **Flutter:** SDK ^3.8.1
* **Dart:** ^3.0.0
* **Backend:** API REST operativa (Node.js) o instancia de Supabase.

---

## 📥 Instalación

1.  **Clona el repositorio:**
    ```bash
    git clone [https://github.com/evaluacionsismica2002-ui/PROYECTO-EVALUACION-SISIMICA-FRONTEND.git](https://github.com/evaluacionsismica2002-ui/PROYECTO-EVALUACION-SISIMICA-FRONTEND.git)
    cd flutter_application_1
    ```

2.  **Instala las dependencias:**
    ```bash
    flutter pub get
    ```

3.  **Configura el entorno:**
    Actualiza las credenciales en: `lib/core/config/database_config.dart`

4.  **Ejecuta la aplicación:**
    ```bash
    flutter run
    ```

---

## 📁 Estructura de Archivos (Proyecto)

```text
.
├── assets/             # Recursos estáticos (Imágenes, Iconos)
├── android/            # Código nativo Android
├── ios/                # Código nativo iOS
├── lib/                # Código fuente Dart
│   ├── core/           # Servicios y Configuración
│   ├── data/           # Capa de datos y Modelos
│   └── ui/             # Pantallas y Widgets
├── pubspec.yaml        # Gestión de dependencias
└── README.md           # Documentación del proyecto 
