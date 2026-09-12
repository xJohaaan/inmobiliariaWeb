<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Locale" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%
    String usuario = (String) session.getAttribute("usuarioLogueado");
    String txt = request.getParameter("txt");
    String pCiudad = request.getParameter("ciudad");
    String pTipo = request.getParameter("tipo");
    String pMin = request.getParameter("pmin");
    String pMax = request.getParameter("pmax");
    if (txt == null) txt = "";
    if (pCiudad == null) pCiudad = "";
    if (pTipo == null) pTipo = "";
    if (pMin == null) pMin = "";
    if (pMax == null) pMax = "";

    Connection con = null;
    java.util.ArrayList<Integer> ids = new java.util.ArrayList<Integer>();
    java.util.ArrayList<String> titulos = new java.util.ArrayList<String>();
    java.util.ArrayList<String> ubi = new java.util.ArrayList<String>();
    java.util.ArrayList<String> tipos = new java.util.ArrayList<String>();
    java.util.ArrayList<Double> precios = new java.util.ArrayList<Double>();
    java.util.ArrayList<String> imgs = new java.util.ArrayList<String>();
    int total = 0;
    try {
        con = obtenerConexion();
        StringBuilder sql = new StringBuilder(
            "SELECT p.id_propiedad, p.titulo_publicacion, p.precio, tp.nombre AS tipo, b.nombre_barrio, c.nombre_ciudad, " +
            "(SELECT url_ruta_imagen FROM imagen_propiedad i WHERE i.id_propiedad=p.id_propiedad ORDER BY i.id_imagen LIMIT 1) AS img " +
            "FROM propiedad p " +
            "JOIN tipo_propiedad tp ON tp.id_tipo=p.id_tipo " +
            "JOIN barrio b ON b.id_barrio=p.id_barrio " +
            "JOIN ciudad c ON c.id_ciudad=b.id_ciudad " +
            "WHERE p.estado='Disponible'");
        java.util.ArrayList<Object> params = new java.util.ArrayList<Object>();
        if (!txt.trim().isEmpty()) {
            sql.append(" AND (p.titulo_publicacion LIKE ? OR p.descripcion LIKE ?)");
            params.add("%" + txt.trim() + "%"); params.add("%" + txt.trim() + "%");
        }
        if (!pCiudad.isEmpty()) { sql.append(" AND c.id_ciudad = ?"); params.add(Integer.parseInt(pCiudad)); }
        if (!pTipo.isEmpty()) { sql.append(" AND p.id_tipo = ?"); params.add(Integer.parseInt(pTipo)); }
        if (!pMin.isEmpty()) { sql.append(" AND p.precio >= ?"); params.add(Double.parseDouble(pMin)); }
        if (!pMax.isEmpty()) { sql.append(" AND p.precio <= ?"); params.add(Double.parseDouble(pMax)); }
        sql.append(" ORDER BY p.precio ASC");

        PreparedStatement ps = con.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            ids.add(rs.getInt("id_propiedad"));
            titulos.add(rs.getString("titulo_publicacion"));
            ubi.add(rs.getString("nombre_barrio") + ", " + rs.getString("nombre_ciudad"));
            tipos.add(rs.getString("tipo"));
            precios.add(rs.getDouble("precio"));
            String img = rs.getString("img");
            imgs.add(img != null ? img : "https://picsum.photos/seed/none/900/600");
            total++;
        }
        rs.close(); ps.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        cerrarConexion(con);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catálogo de propiedades - Inmobiliaria</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/estilos.css" rel="stylesheet">
</head>
<body>
<div class="topbar py-2">
    <div class="container d-flex flex-wrap justify-content-between gap-2">
        <div class="d-flex flex-wrap gap-3 align-items-center">
            <a href="tel:6012345678"><i class="bi bi-telephone"></i> (601) 234 5678</a>
            <a href="mailto:contacto@arcoreal.com"><i class="bi bi-envelope"></i> contacto@arcoreal.com</a>
            <span class="sep d-none d-md-inline">L&ndash;V 8am a 5:30pm &middot; S&aacute;b 8am a 12pm</span>
        </div>
        <div class="d-flex gap-3">
            <a href="#"><i class="bi bi-instagram"></i></a>
            <a href="#"><i class="bi bi-facebook"></i></a>
            <a href="#"><i class="bi bi-whatsapp"></i></a>
        </div>
    </div>
</div>

<nav class="navbar navbar-expand-lg navbar-light navbar-inmo sticky-top">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="bi bi-building-check"></i> Inmobiliaria Arco Real</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navCat" aria-controls="navCat" aria-expanded="false" aria-label="Abrir menú">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navCat">
            <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1">
                <li class="nav-item"><a class="nav-link" href="index.jsp">Inicio</a></li>
                <li class="nav-item"><a class="nav-link active" href="buscar.jsp"><i class="bi bi-search"></i> Catálogo</a></li>
                <% if (usuario == null) { %>
                    <li class="nav-item"><a class="nav-link" href="login.jsp">Iniciar Sesión</a></li>
                    <li class="nav-item ms-lg-2"><a class="btn btn-success btn-sm px-3" href="registro.jsp">Registrarse</a></li>
                <% } else { %>
                    <li class="nav-item ms-lg-2"><a class="btn btn-primary btn-sm px-3" href="index.jsp"><i class="bi bi-grid"></i> Mi Panel</a></li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="bi bi-grid"></i> Catálogo de propiedades</h3>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <form method="GET" action="buscar.jsp" class="row g-2 align-items-end">
                <div class="col-12 col-md-3">
                    <label class="form-label small mb-1">Texto</label>
                    <input type="text" name="txt" class="form-control" value="<%= txt %>" placeholder="Título o descripción">
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1">Ciudad</label>
                    <select name="ciudad" class="form-select">
                        <option value="">Todas</option>
                        <%
                            Connection cA = null;
                            try { cA = obtenerConexion();
                                PreparedStatement psA = cA.prepareStatement("SELECT id_ciudad, nombre_ciudad FROM ciudad ORDER BY nombre_ciudad");
                                ResultSet rsA = psA.executeQuery();
                                while (rsA.next()) {
                                    int idC = rsA.getInt(1);
                                    String sel = idC == Integer.parseInt(pCiudad.isEmpty() ? "0" : pCiudad) ? "selected" : "";
                        %><option value="<%= idC %>" <%= sel %>><%= rsA.getString(2) %></option><%
                                }
                                rsA.close(); psA.close();
                            } catch (Exception e) {} finally { cerrarConexion(cA); }
                        %>
                    </select>
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1">Tipo</label>
                    <select name="tipo" class="form-select">
                        <option value="">Todos</option>
                        <%
                            Connection cB = null;
                            try { cB = obtenerConexion();
                                PreparedStatement psB = cB.prepareStatement("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
                                ResultSet rsB = psB.executeQuery();
                                while (rsB.next()) {
                                    int idT = rsB.getInt(1);
                                    String sel = idT == Integer.parseInt(pTipo.isEmpty() ? "0" : pTipo) ? "selected" : "";
                        %><option value="<%= idT %>" <%= sel %>><%= rsB.getString(2) %></option><%
                                }
                                rsB.close(); psB.close();
                            } catch (Exception e) {} finally { cerrarConexion(cB); }
                        %>
                    </select>
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1">Precio mín</label>
                    <input type="number" name="pmin" class="form-control" value="<%= pMin %>" min="0" step="1000000">
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1">Precio máx</label>
                    <input type="number" name="pmax" class="form-control" value="<%= pMax %>" min="0" step="1000000">
                </div>
                <div class="col-12 col-md-1 d-grid">
                    <button type="submit" class="btn btn-primary"><i class="bi bi-funnel"></i></button>
                </div>
            </form>
        </div>
    </div>

    <p class="text-muted"><%= total %> propiedad(es) encontrada(s)</p>

    <div class="row g-4">
        <% for (int i = 0; i < ids.size(); i++) { %>
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card h-100 shadow-sm card-propiedad">
                    <img src="<%= imgs.get(i) %>" class="card-img-top img-card" alt="<%= titulos.get(i) %>">
                    <div class="card-body">
                        <span class="badge bg-secondary mb-2"><%= tipos.get(i) %></span>
                        <h5 class="card-title"><%= titulos.get(i) %></h5>
                        <p class="text-muted mb-2"><i class="bi bi-geo-alt"></i> <%= ubi.get(i) %></p>
                        <p class="precio mb-3">$ <%= String.format(Locale.US, "%,.0f", precios.get(i)) %></p>
                        <a href="propiedad.jsp?id=<%= ids.get(i) %>" class="btn btn-sm btn-primary w-100">Ver ficha</a>
                    </div>
                </div>
            </div>
        <% } %>
        <% if (ids.isEmpty()) { %>
            <div class="col-12"><div class="alert alert-warning">No se encontraron propiedades con esos filtros.</div></div>
        <% } %>
    </div>
</div>

<footer class="footer-inmo py-4 mt-5">
    <div class="container text-center">
        <a href="index.jsp"><i class="bi bi-arrow-left"></i> Volver al inicio</a>
    </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>