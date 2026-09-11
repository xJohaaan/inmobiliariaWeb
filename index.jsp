<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%
    String usuario = (String) session.getAttribute("usuarioLogueado");
    if (usuario == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<String> roles = (List<String>) session.getAttribute("usuarioRoles");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">Inmobiliaria</a>
            <div class="d-flex">
                <span class="navbar-text me-3">Bienvenido, <%= usuario %></span>
                <a href="logout.jsp" class="btn btn-outline-light btn-sm">Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h4 class="mb-4">Panel de Inicio</h4>

        <% if (roles != null && roles.contains("admin")) { %>
            <a href="admin/index.jsp" class="btn btn-outline-primary mb-2">Panel de Administración</a>
        <% } %>
        <% if (roles != null && roles.contains("agente")) { %>
            <a href="agente/index.jsp" class="btn btn-outline-primary mb-2">Panel de Agente</a>
        <% } %>
        <% if (roles != null && roles.contains("cliente")) { %>
            <a href="client/index.jsp" class="btn btn-outline-primary mb-2">Panel de Cliente</a>
        <% } %>

        <div class="alert alert-info mt-3">
            Los menús se muestran dinámicamente según el rol: <%= roles != null ? String.join(", ", roles) : "sin roles asignados" %>.
        </div>
    </div>
</body>
</html>