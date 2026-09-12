# AGENTS.md

Aplicación web **JSP + JDBC** para un sistema "inmobiliaria". **No build tool, no tests, no linter.** Se despliega directamente en XAMPP Tomcat (`C:\xampp\tomcat\webapps\inmobiliariaWeb`, que es la raíz de este repo).

## Tomcat / namespace (dato crítico)

- El XAMPP instalado usa **Tomcat 8.5.96 → `javax.servlet.*`**, NO `jakarta.*`. Todo el código Java debe importar `javax.servlet`.
- Corre sobre **JDK 24** (`C:\Program Files\Java\jdk-24`).
- `WEB-INF/classes` y `WEB-INF/lib` son locales (.gitignore excluye `*.class`, `*.jar`, `*.war`). El driver `mysql-connector-j-8.0.33.jar` debe estar presente en `WEB-INF/lib`.
- `WEB-INF/web.xml` (local, versionado) configura el `multipart-config` sobre el JspServlet: **requerido** para subir documentos vía `request.getParts()`.
- Tras cambios en `web.xml`, código Java o el filtro hay que **reiniciar Tomcat**. `shutdown.bat`/`startup.bat` requieren `CATALINA_HOME=C:\xampp\tomcat` y `JAVA_HOME=C:\Program Files\Java\jdk-24`.
- Si una JSP quedó "pegada" con una clase corrupta (ClassNotFoundException), borrar `C:\xampp\tomcat\work\Catalina\localhost\inmobiliariaWeb` y reiniciar para recompilar todo.

## Arquitectura: JSP + JDBC (sin servlets de negocio)

- Raíz del repo = web root. JSPs servidas directo. **Toda la lógica vive en las JSP** (auto-procesadas: POST a sí mismas o a `controlador_*.jsp`), siguiendo el patrón del curso. No hay DAO/servlets de negocio.
- `WEB-INF/jspf/conexion.jspf` **centraliza la conexión JDBC** (driver, URL, usuario, contraseña) y define `obtenerConexion()` / `cerrarConexion()`. Es el **único** lugar para cambiar credenciales.
- Vistas públicas en la raíz (`index.jsp` landing, `buscar.jsp`, `propiedad.jsp`); paneles privados en `admin/`, `agente/`, `cliente/`.
- Fragmentos base en `WEB-INF/jspf`: `seguridad.jspf` (control de rol por sesión), `auditoria.jspf` (`registrarAuditoria(con, idUsuario, accion)` → tabla `auditoria`), `cabecera_dash.jspf` (navbar de paneles, requiere `__tituloPanel`).
- **Includes relativos:** desde una subcarpeta SIEMPRE con `../../WEB-INF/jspf/...`; desde la raíz con `WEB-INF/jspf/...`. Un include sin `../../` en paneles rompe la página con "JSP no encontrado".
- Los `ignorar.txt` vacíos mantienen carpetas vacías en git — no borrarlos.
- `src/` solo contiene el código Java del filtro (`src/main/java/com/inmobiliaria/filter/AuthFilter.java`). No existe `src/main/web` ni `src/WEB-INF`: el web root ES la raíz del repo. El layout Maven legacy (servlets/DAO) se eliminó — no reintroducirlo.

## Única clase Java compilada: AuthFilter

El requisito exige un `Filter` de servlet para proteger rutas privadas.

- `src/main/java/com/inmobiliaria/filter/AuthFilter.java` (usa `javax.servlet`, anotación `@WebFilter`).
- Protege `/admin/*`, `/agente/*`, `/cliente/*`: exige sesión (`usuarioLogueado`) **y** rol presente en `usuarioRoles` para esa ruta → redirige a `acceso.jsp`.
- Compilar manualmente:
  `javac -encoding UTF-8 -cp "C:\xampp\tomcat\lib\servlet-api.jar" -d WEB-INF/classes src\main\java\com\inmobiliaria\filter\AuthFilter.java`
- Tras recompilar hay que **reiniciar Tomcat** para recargar el filtro.

## Flujo de autenticación y sesión

- `registro.jsp`: valida obligatorios/formato, genera salt (16 bytes Base64) y cifra **SHA-256 + salt**; inserta en `usuario` con estado `'Activa'` y asigna **rol `cliente` por defecto** (vía `usuario_rol`). Correo duplicado se detecta por SQLState prefijo `"23"`.
- `login.jsp`: consulta `usuario`, verifica el hash con el salt, rechaza `estado='Inactiva'`; guarda en sesión `usuarioLogueado` (correo), `idUsuario` (Integer) y `usuarioRoles` (`List<String>` en minúsculas); redirige a `admin/index.jsp`, `agente/index.jsp` o `cliente/index.jsp` según rol.
- `logout.jsp`: invalida la sesión. `acceso.jsp`: aviso de acceso denegado.
- `index.jsp` (landing): botón "Mi Panel" apunta a `rutaPanel` según el primer rol de `usuarioRoles`; si el usuario no tiene rol, cae en `index.jsp` (parece "no hace nada") → la asignación de roles la hace el admin en `admin/usuarios.jsp`.
- Cada JSP privada valida rol con: `session.setAttribute("__rolesRequeridos", new String[]{"admin"})` ANTES del include de `seguridad.jspf`. Las acciones con JSP incluyen `auditoria.jspf` y llaman `registrarAuditoria(...)`.

## Base de datos

- MySQL `inmobiliaria_db`, usuario `root`. Credenciales hardcodeadas en `WEB-INF/jspf/conexion.jspf`.
- `usuario`: `id_usuario`, `correo` (UNIQUE), `contrasena` (SHA-256 hex), `salt` (Base64), `estado` enum `('Activa','Inactiva')`.
- `rol` (1=admin, 2=agente, 3=cliente) y `usuario_rol` (N:M).
- `propiedad`: `matricula_inmobiliaria` (UNIQUE), `id_inmobiliaria`, `id_barrio`, `id_tipo`, `titulo_publicacion`, `descripcion`, `precio`, `estado` enum `('Disponible','Alquilado','Vendido','De_baja')` (baja = lógica).
- `imagen_propiedad` (URLs), `propiedad_caracteristica` (con `cantidad`), `cita` (`fecha_hora`; estados `Pendiente/Aprobada/Rechazada`), `solicitud` (estados `En revisión/Aprobada/Rechazada`), `documento_solicitud` (nombre y ruta del archivo subido), `auditoria`, `favorito`, `perfil`, `inmobiliaria`, `ciudad`, `barrio`, `tipo_propiedad`, `caracteristica`, `usuario_rol`, `mensaje`.
- Subida de documentos → `uploads/solicitudes/` con nombre `timestamp-idSolicitud-nombreOriginal`.

## Convenciones

- UI, comentarios y mensajes de commit en **español**.
- JSP con scriptlets clásicos (`<% %>`) y Bootstrap 5 por CDN con `<meta viewport>`. **No** usar JSTL/EL.
- Redirecciones siempre con `request.getContextPath()` + ruta absoluta.
- Cuentas de prueba: `cliente1@test.com`, `agente1@inmobiliaria.com`, `admin@test.com` (todas clave `clave123`).
- No hay tests. Verificación manual: `http://localhost:8080/inmobiliariaWeb/login.jsp`.