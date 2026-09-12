<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Locale" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%
    int idProp = 0;
    try { idProp = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { idProp = 0; }
    String usuario = (String) session.getAttribute("usuarioLogueado");
    Integer idUsuario = (Integer) session.getAttribute("idUsuario");
    java.util.List<String> roles = (java.util.List<String>) session.getAttribute("usuarioRoles");
    boolean esCliente = roles != null && roles.contains("cliente");

    String titulo = "", desc = "", base = "", tipo = "", barrioCiudad = "", inmob = "", tel = "", correoInmob = "";
    double precio = 0; String estado = "";
    java.util.ArrayList<String> imgs = new java.util.ArrayList<String>();
    java.util.ArrayList<String[]> caracts = new java.util.ArrayList<String[]>();
    boolean esFavorito = false;
    boolean encontrada = false;

    Connection con = null;
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT p.titulo_publicacion, p.descripcion, p.precio, p.estado, tp.nombre AS tipo, " +
            "b.nombre_barrio, c.nombre_ciudad, i.nombre_empresa, i.telefono, i.correo_contacto " +
            "FROM propiedad p JOIN tipo_propiedad tp ON tp.id_tipo=p.id_tipo " +
            "JOIN barrio b ON b.id_barrio=p.id_barrio JOIN ciudad c ON c.id_ciudad=b.id_ciudad " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria=p.id_inmobiliaria WHERE p.id_propiedad=? AND p.estado<>'De_baja'");
        ps.setInt(1, idProp);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            encontrada = true;
            titulo = rs.getString("titulo_publicacion");
            String d = rs.getString("descripcion");
            desc = d != null ? d : "";
            precio = rs.getDouble("precio");
            estado = rs.getString("estado");
            tipo = rs.getString("tipo");
            barrioCiudad = rs.getString("nombre_barrio") + ", " + rs.getString("nombre_ciudad");
            inmob = rs.getString("nombre_empresa");
            tel = rs.getString("telefono"); if (tel == null) tel = "";
            correoInmob = rs.getString("correo_contacto"); if (correoInmob == null) correoInmob = "";
        }
        rs.close(); ps.close();

        if (encontrada) {
            PreparedStatement pi = con.prepareStatement("SELECT url_ruta_imagen FROM imagen_propiedad WHERE id_propiedad=? ORDER BY id_imagen");
            pi.setInt(1, idProp);
            ResultSet ri = pi.executeQuery();
            while (ri.next()) imgs.add(ri.getString(1));
            ri.close(); pi.close();
            if (imgs.isEmpty()) imgs.add("https://picsum.photos/seed/none/900/600");

            PreparedStatement pc = con.prepareStatement(
                "SELECT ca.nombre, pc.cantidad FROM propiedad_caracteristica pc JOIN caracteristica ca ON ca.id_caracteristica=pc.id_caracteristica WHERE pc.id_propiedad=?");
            pc.setInt(1, idProp);
            ResultSet rc = pc.executeQuery();
            while (rc.next()) caracts.add(new String[]{rc.getString(1), String.valueOf(rc.getInt(2))});
            rc.close(); pc.close();

            if (esCliente && idUsuario != null) {
                PreparedStatement pf = con.prepareStatement("SELECT id_favorito FROM favorito WHERE id_usuario=? AND id_propiedad=?");
                pf.setInt(1, idUsuario); pf.setInt(2, idProp);
                ResultSet rf = pf.executeQuery();
                esFavorito = rf.next();
                rf.close(); pf.close();
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        cerrarConexion(con);
    }

    if (!encontrada) { response.sendRedirect("buscar.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %> - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/estilos.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-light navbar-inmo sticky-top">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="bi bi-building-check"></i> Inmobiliaria Arco Real</a>
        <div class="d-flex gap-2 align-items-center">
            <a class="nav-link" href="buscar.jsp"><i class="bi bi-arrow-left"></i> Volver al catálogo</a>
            <% if (usuario != null) { %><a class="nav-link" href="login.jsp"><i class="bi bi-person-circle"></i> <%= usuario %></a><% } %>
        </div>
    </div>
</nav>

<div class="container py-4">
    <% 
        String flash = (String) session.getAttribute("flashCita");
        if (flash != null) { session.removeAttribute("flashCita"); %>
        <div class="alert alert-info"><%= flash %></div>
    <% } %>

    <div class="row g-4">
        <div class="col-lg-7">
            <img id="imgPrincipal" src="<%= imgs.get(0) %>" class="img-fluid rounded-4 shadow-sm img-destacada w-100" alt="<%= titulo %>" style="height:380px;object-fit:cover">
            <div class="mt-2 d-flex gap-2 flex-wrap">
                <% for (int i = 1; i < imgs.size(); i++) { %>
                    <img src="<%= imgs.get(i) %>" class="miniatura" onclick="document.getElementById('imgPrincipal').src=this.src" alt="foto <%= i %>">
                <% } %>
                <% if (imgs.size() <= 1) { %><span class="text-muted small">Solo hay una imagen registrada.</span><% } %>
            </div>
        </div>
        <div class="col-lg-5">
            <span class="badge bg-secondary mb-2"><%= tipo %></span>
            <span class="badge bg-success mb-2"><%= estado %></span>
            <h2 class="fw-bold"><%= titulo %></h2>
            <p class="text-muted"><i class="bi bi-geo-alt"></i> <%= barrioCiudad %></p>
            <h3 class="precio">$ <%= String.format(Locale.US, "%,.0f", precio) %></h3>
            <hr>
            <h6 class="fw-bold">Descripción</h6>
            <p><%= desc %></p>

            <% if (esCliente) { %>
                <div class="mt-3 d-flex flex-column gap-2">
                    <a href="cliente/controlador_favorito.jsp?id=<%= idProp %>" class="btn <%= esFavorito ? "btn-warning" : "btn-outline-warning" %>">
                        <i class="bi bi-heart<%= esFavorito ? "-fill" : "" %>"></i> <%= esFavorito ? "Quitar de favoritos" : "Marcar como favorito" %>
                    </a>
                    <form method="POST" action="cliente/controlador_cita.jsp" class="border rounded-3 p-3 bg-white">
                        <input type="hidden" name="id_propiedad" value="<%= idProp %>">
                        <label class="form-label small mb-1">Agendar cita de visita</label>
                        <div class="input-group">
                            <input type="datetime-local" name="fecha_hora" class="form-control" required>
                            <button class="btn btn-primary" type="submit"><i class="bi bi-calendar-check"></i> Agendar</button>
                        </div>
                    </form>
                    <a href="cliente/radicar_solicitud.jsp?id=<%= idProp %>" class="btn btn-outline-success"><i class="bi bi-file-earmark-arrow-up"></i> Radicar solicitud (compra/arriendo)</a>
                </div>
            <% } else if (estado != null && estado.equals("Disponible")) { %>
                <div class="alert alert-secondary mt-3">
                    <i class="bi bi-info-circle"></i> <strong><%= usuario == null ? "Inicia sesión o" : "Tu rol no" %></strong> permite agendar citas o radicar solicitudes.
                    <% if (usuario == null) { %><a href="login.jsp?redir=propiedad.jsp?id=<%= idProp %>">Inicia sesión</a> como cliente para agendar una visita.<% } %>
                </div>
            <% } %>
            <hr>
            <h6 class="fw-bold"><i class="bi bi-building"></i> Publicada por</h6>
            <p class="mb-0"><%= inmob %></p>
            <p class="small text-muted mb-0">
                <% if (usuario != null) { %>
                    <i class="bi bi-telephone"></i> <%= tel %> &nbsp; <i class="bi bi-envelope"></i> <%= correoInmob %>
                <% } else { %>
                    <i class="bi bi-shield-lock"></i> El contacto completo está disponible para usuarios registrados.
                <% } %>
            </p>
        </div>
    </div>

    <div class="card shadow-sm mt-4">
        <div class="card-body">
            <h6 class="fw-bold"><i class="bi bi-list-check"></i> Características del inmueble</h6>
            <div class="row g-2 mt-1">
                <% for (String[] c : caracts) { %>
                    <div class="col-6 col-md-3">
                        <div class="border rounded-3 p-2 text-center bg-light">
                            <div class="fs-4 fw-bold text-primary"><%= c[1] %></div>
                            <div class="small text-muted"><%= c[0] %></div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<footer class="footer-inmo py-4 mt-5">
    <div class="container text-center"><a href="index.jsp"><i class="bi bi-arrow-left"></i> Volver al inicio</a></div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>