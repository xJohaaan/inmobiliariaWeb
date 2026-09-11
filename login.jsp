<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Iniciar Sesión - Inmobiliaria</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 50px; }
        .contenedor { max-width: 400px; margin: auto; border: 1px solid #ccc; padding: 20px; border-radius: 8px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input[type="email"], input[type="password"] { width: 100%; padding: 8px; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background-color: #0056b3; color: white; border: none; cursor: pointer; }
        .alerta { color: red; margin-bottom: 15px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="contenedor">
        <h2>Ingresar al Sistema</h2>

        <%-- Scriptlet para mostrar el error si el usuario falla el login --%>
        <% 
            String error = (String) session.getAttribute("errorLogin");
            if (error != null) { 
        %>
            <div class="alerta"><%= error %></div>
        <% 
                session.removeAttribute("errorLogin"); // Lo borramos para que no salga siempre
            } 
        %>

        <form action="auth" method="POST">
            <!-- Esta variable oculta le dice al Servlet qué método ejecutar -->
            <input type="hidden" name="accion" value="login">
            
            <div class="form-group">
                <label for="correo">Correo Electrónico:</label>
                <input type="email" id="correo" name="correo" required>
            </div>
            
            <div class="form-group">
                <label for="contrasena">Contraseña:</label>
                <input type="password" id="contrasena" name="contrasena" required>
            </div>
            
            <button type="submit">Iniciar Sesión</button>
        </form>
        <p style="text-align: center;">¿No tienes cuenta? <a href="registro.jsp">Regístrate aquí</a></p>
    </div>
</body>
</html>