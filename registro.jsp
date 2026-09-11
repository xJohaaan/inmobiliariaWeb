<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registro - Inmobiliaria</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 50px; }
        .contenedor { max-width: 400px; margin: auto; border: 1px solid #ccc; padding: 20px; border-radius: 8px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input[type="email"], input[type="password"] { width: 100%; padding: 8px; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background-color: #28a745; color: white; border: none; cursor: pointer; }
        .mensaje { font-weight: bold; margin-bottom: 15px; }
        .exito { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="contenedor">
        <h2>Crear Cuenta</h2>

        <%-- Scriptlet para mostrar si se guardó bien o si el correo ya existe --%>
        <% 
            String mensaje = (String) session.getAttribute("mensajeRegistro");
            if (mensaje != null) { 
                String claseCss = mensaje.contains("Error") ? "error" : "exito";
        %>
            <div class="mensaje <%= claseCss %>"><%= mensaje %></div>
        <% 
                session.removeAttribute("mensajeRegistro");
            } 
        %>

        <form action="auth" method="POST">
            <!-- Esta variable oculta le dice al Servlet que es un registro -->
            <input type="hidden" name="accion" value="registrar">
            
            <div class="form-group">
                <label for="correo">Correo Electrónico:</label>
                <input type="email" id="correo" name="correo" required>
            </div>
            
            <div class="form-group">
                <label for="contrasena">Contraseña:</label>
                <input type="password" id="contrasena" name="contrasena" required>
            </div>
            
            <button type="submit">Registrarme</button>
        </form>
        <p style="text-align: center;">¿Ya tienes cuenta? <a href="login.jsp">Inicia sesión aquí</a></p>
    </div>
</body>
</html>