<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList,java.util.List" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%!
    private String cifrarContrasena(String password, String salt) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
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
    String error = (String) session.getAttribute("errorLogin");
    session.removeAttribute("errorLogin");

    String correo = request.getParameter("correo");
    if (correo != null) {
        String contrasena = request.getParameter("contrasena");
        Connection con = null;
        try {
            con = obtenerConexion();
            String sql = "SELECT id_usuario, correo, contrasena, salt, estado FROM usuario WHERE correo = ?";
            PreparedStatement pstmt = con.prepareStatement(sql);
            pstmt.setString(1, correo.trim().toLowerCase());
            ResultSet rs = pstmt.executeQuery();

            boolean valido = false;
            if (rs.next()) {
                String hashBD = rs.getString("contrasena");
                String saltBD = rs.getString("salt");
                if (saltBD != null && hashBD != null) {
                    String hashCalculado = cifrarContrasena(contrasena, saltBD);
                    valido = hashCalculado != null && hashCalculado.equals(hashBD);
                }

                if (valido && "Inactiva".equals(rs.getString("estado"))) {
                    error = "Tu cuenta está inactiva.";
                } else if (valido) {
                    // Guardamos en la sesión: identificador del usuario y sus roles
                    session.setAttribute("usuarioLogueado", rs.getString("correo"));
                    session.setAttribute("idUsuario", rs.getInt("id_usuario"));

                    List<String> roles = new ArrayList<String>();
                    String sqlRoles = "SELECT r.nombre FROM rol r INNER JOIN usuario_rol ur ON ur.id_rol = r.id_rol WHERE ur.id_usuario = ?";
                    PreparedStatement psRoles = con.prepareStatement(sqlRoles);
                    psRoles.setInt(1, rs.getInt("id_usuario"));
                    ResultSet rsRoles = psRoles.executeQuery();
                    while (rsRoles.next()) {
                        roles.add(rsRoles.getString("nombre").toLowerCase());
                    }
                    rsRoles.close();
                    psRoles.close();
                    session.setAttribute("usuarioRoles", roles);

                    // Redirección automática según el rol asignado
                    String destino = "index.jsp";
                    if (roles.contains("admin")) destino = "admin/index.jsp";
                    else if (roles.contains("agente")) destino = "agente/index.jsp";
                    else if (roles.contains("cliente")) destino = "cliente/index.jsp";
                    response.sendRedirect(destino);
                    return;
                }
            }
            if (!valido) {
                error = "Credenciales incorrectas.";
            }
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            error = "Error de conexión con la base de datos.";
            e.printStackTrace();
        } finally {
            cerrarConexion(con);
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/estilos.css" rel="stylesheet">
</head>
<body class="page-auth">
    <div class="card card-auth">
        <div class="card-body p-4">
            <a class="auth-logo" href="index.jsp"><i class="bi bi-building-check"></i> Inmobiliaria Arco Real</a>
            <h2 class="text-center mb-4 fs-4">Ingresar al Sistema</h2>

                <% if (error != null) { %>
                    <div class="alert alert-danger"><%= error %></div>
                <% } %>

                <form method="POST" action="login.jsp" novalidate>
                    <div class="mb-3">
                        <label for="correo" class="form-label">Correo Electrónico:</label>
                        <input type="email" class="form-control" id="correo" name="correo" value="<%= correo != null ? correo.trim() : "" %>" required>
                    </div>
                    <div class="mb-3">
                        <label for="contrasena" class="form-label">Contraseña:</label>
                        <input type="password" class="form-control" id="contrasena" name="contrasena" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Iniciar Sesión</button>
                </form>
                <p class="text-center mt-3 mb-0">¿No tienes cuenta? <a href="registro.jsp">Regístrate aquí</a></p>
            </div>
        </div>
</body>
</html>