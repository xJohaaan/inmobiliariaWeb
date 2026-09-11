<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acceso Denegado - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .contenedor { max-width: 520px; margin: 80px auto; }
    </style>
</head>
<body>
    <div class="contenedor">
        <div class="card shadow text-center">
            <div class="card-body p-4">
                <h1 class="display-6 text-danger mb-3">Acceso Denegado</h1>
                <p class="text-muted">No tienes una sesión activa o no tienes el rol necesario para ver esta página.</p>
                <a href="login.jsp" class="btn btn-primary">Ir al Login</a>
            </div>
        </div>
    </div>
</body>
</html>