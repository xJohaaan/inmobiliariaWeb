# AGENTS.md

Aplicación web **JSP + JDBC** para un sistema "inmobiliaria". **No build tool, no tests, no linter.** Se despliega directamente en XAMPP Tomcat (`C:\xampp\tomcat\webapps\inmobiliariaWeb`, que es la raíz de este repo).

## Tomcat / namespace (dato crítico)

- El XAMPP instalado usa **Tomcat 8.5.96 → `javax.servlet.*`**, NO `jakarta.*`. Todo el código Java debe importar `javax.servlet`.
- Corre sobre **JDK 24** (`C:\Program Files\Java\jdk-24`).
- No existe `WEB-INF` en el working tree por defecto: `WEB-INF/classes` y `WEB-INF/lib` son locales (.gitignore excluye `*.class`, `*.jar`, `*.war`).

## Arquitectura: JSP + JDBC (sin servlets de negocio)

- Raíz del repo = web root. JSPs servidas directo: `login.jsp`, `registro.jsp`, `index.jsp`, `acceso.jsp`, `logout.jsp`.
- **La autenticación vive en las propias JSP**, no en un servlet: `registro.jsp` y `login.jsp` se auto-procesan (POST a sí mismas), siguiendo el patrón del curso.
- `WEB-INF/jspf/conexion.jspf` **centraliza la conexión JDBC** (driver, URL, usuario, contraseña) y define `obtenerConexion()` / `cerrarConexion()`. Se incluye con `<%@ include file="WEB-INF/jspf/conexion.jspf" %>`. Es el **único** lugar para cambiar credenciales.
- `WEB-INF/lib/mysql-connector-j-8.0.33.jar` debe estar presente localmente (no se versiona).
- Vistas por rol: `src/main/web/{admin,agente,client,css}`; fragmentos privados en `src/WEB-INF/jspf` (y su copia activa en `WEB-INF/jspf`).
- Los `ignorar.txt` vacíos mantienen carpetas vacías en git — no borrarlos.
- **Legacy / no usar:** `src/main/java/com/inmobiliaria/{controller/AuthServlet,dao,config,model,util}` son de un diseño con servlets abandonado. No compilar ni enlazar; la lógica real está en las JSP.

## Única clase Java compilada: AuthFilter

El requisito exige un `Filter` de servlet para proteger rutas privadas.

- `src/main/java/com/inmobiliaria/filter/AuthFilter.java` (usa `javax.servlet`, anotación `@WebFilter`).
- Protege `/admin/*`, `/agente/*`, `/cliente/*`: exige sesión (`usuarioLogueado`) **y** rol (`usuarioRoles`) → redirige a `acceso.jsp`.
- **Mismatch conocido:** el patrón es `/cliente/*` pero la carpeta es `client`, así que `/client/*` queda sin proteger.
- Compilar manualmente:
  `javac -encoding UTF-8 -cp "C:\xampp\tomcat\lib\servlet-api.jar" -d WEB-INF/classes src\main\java\com\inmobiliaria\filter\AuthFilter.java`
- Tras recompilar hay que **reiniciar Tomcat** para recargar el filtro. `shutdown.bat`/`startup.bat` requieren `CATALINA_HOME=C:\xampp\tomcat` y `JAVA_HOME=C:\Program Files\Java\jdk-24`.

## Flujo de autenticación

- `registro.jsp`: valida obligatorios/formato, genera salt (16 bytes Base64) y cifra **SHA-256 + salt**; inserta en `usuario` con estado `'Activa'`. Correo duplicado se detecta por SQLState prefijo `"23"`.
- `login.jsp`: consulta `usuario`, verifica el hash con el salt, valida estado `Inactiva`; guarda en sesión `usuarioLogueado` (correo), `idUsuario` y `usuarioRoles` (`List<String>` en minúsculas desde `rol`/`usuario_rol`); redirige a `index.jsp`.
- `logout.jsp`: invalida la sesión.
- `index.jsp`: muestra menú dinámico según `usuarioRoles` (la validación real la hace el filtro, no el ocultar botones).

## Base de datos

- MySQL `inmobiliaria_db`, usuario `root`. Credenciales hardcodeadas en `WEB-INF/jspf/conexion.jspf`.
- `usuario`: `id_usuario`, `correo` (UNIQUE), `contrasena` (hash), `salt`, `estado` enum `('Activa','Inactiva')`.
- `rol` (1=admin, 2=agente, 3=cliente) y `usuario_rol` (N:M).

## Convenciones

- UI, comentarios y mensajes de commit en **español**.
- JSP con scriptlets clásicos (`<% %>`) y Bootstrap 5 por CDN con `<meta viewport>`. **No** usar JSTL/EL.
- No hay tests. Verificación manual: `http://localhost:8080/inmobiliariaWeb/login.jsp`.
