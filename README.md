Este informe técnico presenta el análisis de ingeniería inversa del sistema **"Ventas y Facturación SCT"** (referido internamente como "Sistema de Ventas"), desarrollado en Visual FoxPro (VFP). El análisis se basa en la estructura de archivos y el código fuente proporcionado.

### 1. OBJETIVO DEL SISTEMA

El sistema es un **ERP (Enterprise Resource Planning) especializado en comercialización y distribución**, con un enfoque crítico en la **facturación electrónica (CPE)** y el control de **inventarios valorizados (Kardex)**.

*   **Para qué sirve:** Gestiona el ciclo completo de ventas, desde la cotización y el seguimiento de visitas hasta el despacho y la cobranza, asegurando el cumplimiento tributario ante la SUNAT.
*   **Problema que resuelve:** Automatiza la generación de comprobantes de pago electrónicos (UBL 2.1), el cálculo de costos de venta (promedio y lote) y la trazabilidad de productos químicos o industriales.
*   **Empresa tipo:** Empresas industriales o distribuidoras de químicos, colorantes y maquinaria (menciones constantes a "Sociedad Química" e "Indicolor").
*   **Procesos automatizados:**
    *   **Ventas/Facturación:** Facturas, boletas, notas de crédito/débito y facturación agrupada.
    *   **Logística/Almacén:** Guías de remisión, control de stock por lotes, ingresos de fábrica y transferencias entre almacenes.
    *   **Costos/Contabilidad:** Cálculo de Kardex valorizado y reportes de utilidad por cliente/producto.
    *   **Importaciones:** Gestión de "Venta Sucesiva" y seguimiento de embarques.

### 2. TECNOLOGÍAS DETECTADAS

| Categoría | Tecnologías Específicas |
| :--- | :--- |
| **Lenguaje Principal** | **Visual FoxPro 9.0** (basado en el uso de `REPORTBEHAVIOR 80` y estructuras `.SCT`/`.VCX`). |
| **Base de Datos** | Híbrida: **MySQL** (servidor central) y **DBF/DBC** (tablas locales/temporales y legacy). |
| **Conectividad** | **ODBC 3.51** Driver de MySQL para conexiones remotas vía `SQLSTRINGCONNECT`. |
| **Reportes** | **FoxyPreviewer** (extensión de reportes VFP) y archivos `.FRX/.FRT` nativos. |
| **Integración/API** | **SUNAT CPE:** Generación de archivos TXT para middleware de facturación (UBL 2.1). |
| **Automatización** | **Excel Automation** y librerías para exportación directa de cursores. |
| **Seguridad** | Funciones de encriptación personalizadas basadas en operaciones de bits (`BITXOR`, `BITAND`). |
| **Otros Componentes** | **ActiveX (MSWinsock)** para detección de IP y **WebBrowser Control** para Google Maps. |

### 3. ARQUITECTURA DEL SISTEMA

El sistema presenta una arquitectura **híbrida Cliente-Servidor / Monolítica**.

*   **Arquitectura General:** El cliente VFP maneja la interfaz de usuario (UI) y la lógica de negocio, conectándose a una base de datos centralizada en MySQL para la persistencia de datos transaccionales, mientras usa archivos DBF locales para configuraciones o datos históricos específicos.
*   **Capas:**
    *   **UI:** Formularios (`.SCX`) que integran controles ActiveX y clases visuales (`.VCX`).
    *   **Negocio:** Implementada principalmente en procedimientos (`.PRG`) extensos que contienen reglas de validación y cálculos de impuestos.
    *   **Datos:** Uso intensivo de **SQL Passthrough** para ejecutar consultas directas al servidor MySQL y `APPEND FROM DBF` para migrar datos locales.
*   **Patrón de Diseño:** Predomina el modelo de "Smart UI" o aplicaciones orientadas a eventos, con un fuerte acoplamiento entre la interfaz y el acceso a datos mediante cursores.

### 4. MÓDULOS FUNCIONALES

1.  **Módulo de Ventas:** Gestión de cotizaciones, pedidos web y seguimiento de visitas de vendedores.
2.  **Módulo de Facturación (CPE):** Motor de generación de comprobantes electrónicos (UBL 2.1), incluyendo notas de crédito y débito vinculadas.
3.  **Módulo de Almacén e Inventarios:** Control de ingresos, salidas, trazabilidad por lote y generación de guías de remisión.
4.  **Módulo de Costos y Kardex:** Cálculo automático de saldos iniciales, movimientos valorizados y utilidades.
5.  **Módulo de Comercio Exterior:** Específicamente para la gestión de "Venta Sucesiva" e importaciones relacionadas con productos químicos.
6.  **Módulo de Créditos y Cobranzas:** Seguimiento de deudas de clientes, letras y promedios de días de cancelación.

### 5. MODELO DE DATOS (INFERIDO)

| Tabla | Tipo | Descripción |
| :--- | :--- | :--- |
| `factura` / `boleta` | Transaccional | Cabeceras de documentos de venta. |
| `detafacturas` / `detaboletas` | Transaccional | Detalle de productos vendidos. |
| `clientes` | Maestra | Datos del receptor, incluyendo RUC y tipos de documento SUNAT. |
| `productos` | Maestra | Catálogo de artículos con clasificación por tipo y stock. |
| `vtalotes` | Transaccional | Control específico de ingresos de stock y costos por lote. |
| `k_sunatelectronica` | Configuración | Mensajes y parámetros para la facturación electrónica. |
| `mastersalidas` / `detallesalidas` | Transaccional | Control de movimientos de inventario no relacionados con ventas directas. |

### 6. INTEGRACIONES Y SEGURIDAD

*   **SUNAT:** Integración crítica mediante la generación de archivos TXT estructurados (Pipe-separated) que luego son procesados por un proveedor de servicios electrónicos (PSE) o un facturador local.
*   **Office:** Automatización avanzada de Excel para generar reportes dinámicos de Kardex y listas de precios.
*   **Seguridad:**
    *   **Autenticación:** Gestión de usuarios mediante variables públicas (`Vusuario`) y validación de claves en formularios dedicados.
    *   **Encriptación:** Algoritmo propio para proteger cadenas de texto y llaves de conexión.
    *   **Validaciones:** Fuertes validaciones de integridad para evitar facturar productos sin stock o con inconsistencias en el IGV.

### 7. RIESGOS Y ESTRATEGIA DE MODERNIZACIÓN

**Riesgos Detectados:**
*   **Hardcode:** IPs de servidores (`192.168.1.179`), credenciales de base de datos y rutas de red (`O:\ventas`, `F:\comercio`) están incrustados directamente en el código.
*   **Obsolescencia:** El uso de ODBC 3.51 y la arquitectura de 32 bits dificultan la migración a sistemas operativos modernos y entornos en la nube.
*   **Mantenibilidad:** El código contiene una mezcla de lógica procedimental y visual, lo que genera un "código espagueti" difícil de escalar.

**Estrategia Recomendada:**
1.  **Desacoplamiento de Datos:** Migrar la lógica de los `.PRG` a Procedimientos Almacenados (Stored Procedures) en MySQL o SQL Server para centralizar las reglas de negocio.
2.  **API de Facturación:** Reemplazar la generación de archivos TXT por una API REST que se comunique directamente con el PSE o SUNAT, eliminando la dependencia de rutas de red locales.
3.  **Modernización de Frontend:** Desarrollar una aplicación web (React o Angular) o una App de escritorio moderna (.NET 8/C#) que consuma servicios REST, permitiendo la movilidad y el acceso multisucursal real.
4.  **Migración de Datos:** Consolidar todos los DBF legacy en la base de datos relacional centralizada para eliminar problemas de corrupción de archivos de índice (`.CDX`).
< 2010-03-25T21:53:00 --> 
< 2019-05-11T08:53:00 --> 
< 2019-09-25T07:44:00 --> 
< 2012-01-12T02:33:00 --> 
