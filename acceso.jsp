<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acceso Denegado - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/estilos.css" rel="stylesheet">
</head>
<body class="page-auth">
    <div class="card card-auth">
        <div class="card-body p-4 text-center">
            <i class="bi bi-shield-x display-4 text-danger"></i>
            <h1 class="fs-3 text-danger mb-3 mt-2">Acceso Denegado</h1>
            <p class="text-muted">No tienes una sesión activa o no tienes el rol necesario para ver esta página.</p>
            <a href="login.jsp" class="btn btn-primary px-4"><i class="bi bi-box-arrow-in-right"></i> Ir al Login</a>
        </div>
    </div>
</body>
</html>