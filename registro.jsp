<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.security.MessageDigest,java.security.SecureRandom,java.util.Base64"%>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%!
    private String generarSalt() {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    private String cifrarContrasena(String password, String salt) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.update(salt.getBytes("UTF-8"));
            byte[] hash = digest.digest(password.getBytes("UTF-8"));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
%>
<%
    String mensaje = (String) session.getAttribute("mensajeRegistro");
    session.removeAttribute("mensajeRegistro");

    String correo = request.getParameter("correo");
    if (correo != null) {
        String contrasena = request.getParameter("contrasena");

        if (correo.trim().isEmpty()) {
            mensaje = "Error: El correo es obligatorio.";
        } else if (!correo.matches("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$")) {
            mensaje = "Error: Formato de correo inválido.";
        } else if (contrasena == null || contrasena.length() < 6) {
            mensaje = "Error: La contraseña debe tener al menos 6 caracteres.";
        } else {
            Connection con = null;
            try {
                con = obtenerConexion();
                String salt = generarSalt();
                String hash = cifrarContrasena(contrasena, salt);
                String sql = "INSERT INTO usuario (correo, contrasena, salt, estado) VALUES (?, ?, ?, 'Activa')";
                PreparedStatement pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
                pstmt.setString(1, correo.trim().toLowerCase());
                pstmt.setString(2, hash);
                pstmt.setString(3, salt);
                int filas = pstmt.executeUpdate();
                if (filas > 0) {
                    ResultSet llaves = pstmt.getGeneratedKeys();
                    if (llaves.next()) {
                        int idNuevo = llaves.getInt(1);
                        PreparedStatement psRol = con.prepareStatement(
                            "INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?, (SELECT id_rol FROM rol WHERE nombre='cliente'))");
                        psRol.setInt(1, idNuevo);
                        psRol.executeUpdate();
                        psRol.close();
                    }
                    llaves.close();
                }
                mensaje = (filas > 0) ? "Registro exitoso" : "Error: No se pudo registrar el usuario.";
            } catch (SQLException e) {
                if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                    mensaje = "Error: El correo ya se encuentra registrado.";
                } else {
                    e.printStackTrace();
                    mensaje = "Error interno en la base de datos.";
                }
            } catch (Exception e) {
                mensaje = "Error de conexión con la base de datos.";
            } finally {
                cerrarConexion(con);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/estilos.css" rel="stylesheet">
</head>
<body class="page-auth">
    <div class="card card-auth">
        <div class="card-body p-4">
            <a class="auth-logo" href="index.jsp"><i class="bi bi-building-check"></i> Inmobiliaria Arco Real</a>
            <h2 class="text-center mb-4 fs-4">Crear Cuenta</h2>

                <% if (mensaje != null) { %>
                    <div class="alert <%= mensaje.contains("Error") ? "alert-danger" : "alert-success" %>"><%= mensaje %></div>
                <% } %>

                <form method="POST" action="registro.jsp" novalidate>
                    <div class="mb-3">
                        <label for="correo" class="form-label">Correo Electrónico:</label>
                        <input type="email" class="form-control" id="correo" name="correo" value="<%= correo != null ? correo.trim() : "" %>" required>
                    </div>
                    <div class="mb-3">
                        <label for="contrasena" class="form-label">Contraseña:</label>
                        <input type="password" class="form-control" id="contrasena" name="contrasena" required
                               minlength="6" placeholder="Mínimo 6 caracteres">
                    </div>
                    <button type="submit" class="btn btn-success w-100">Registrarme</button>
                </form>
                <p class="text-center mt-3 mb-0">¿Ya tienes cuenta? <a href="login.jsp">Inicia sesión aquí</a></p>
            </div>
        </div>
</body>
</html>