<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    int nFav = 0, nCitas = 0, nSolic = 0, nMsj = 0;
    String nombrePerfil = "";
    Connection con = null;
    try {
        con = obtenerConexion();
        PreparedStatement p1 = con.prepareStatement("SELECT COUNT(*) FROM favorito WHERE id_usuario=?");
        p1.setInt(1, idUsr); ResultSet r1 = p1.executeQuery(); if (r1.next()) nFav = r1.getInt(1); r1.close(); p1.close();
        PreparedStatement p2 = con.prepareStatement("SELECT COUNT(*) FROM cita WHERE id_usuario=?");
        p2.setInt(1, idUsr); ResultSet r2 = p2.executeQuery(); if (r2.next()) nCitas = r2.getInt(1); r2.close(); p2.close();
        PreparedStatement p3 = con.prepareStatement("SELECT COUNT(*) FROM solicitud WHERE id_usuario=?");
        p3.setInt(1, idUsr); ResultSet r3 = p3.executeQuery(); if (r3.next()) nSolic = r3.getInt(1); r3.close(); p3.close();
        PreparedStatement p4 = con.prepareStatement("SELECT nombres, apellidos FROM perfil WHERE id_usuario=?");
        p4.setInt(1, idUsr); ResultSet r4 = p4.executeQuery();
        if (r4.next()) nombrePerfil = r4.getString(1) + " " + r4.getString(2);
        r4.close(); p4.close();
        PreparedStatement p5 = con.prepareStatement("SELECT COALESCE(SUM(leido=0),0) FROM mensaje WHERE id_destinatario=?");
        p5.setInt(1, idUsr); ResultSet r5 = p5.executeQuery(); if (r5.next()) nMsj = r5.getInt(1); r5.close(); p5.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Panel del Cliente";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<% if (nombrePerfil.trim().isEmpty()) { %>
    <div class="alert alert-warning d-flex justify-content-between align-items-center">
        <span>Completa tu perfil con documento, teléfono y dirección para agilizar tus trámites.</span>
        <a href="perfil.jsp" class="btn btn-sm btn-warning">Completar perfil</a>
    </div>
<% } %>

<div class="row g-4">
    <div class="col-12 col-md-3">
        <div class="card text-bg-primary shadow-sm h-100">
            <div class="card-body">
                <i class="bi bi-heart-fill display-4"></i>
                <h5 class="mt-2"><%= nFav %> favoritos</h5>
                <a href="mis_favoritos.jsp" class="text-white">Ver favoritos</a>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-3">
        <div class="card text-bg-success shadow-sm h-100">
            <div class="card-body">
                <i class="bi bi-calendar-check display-4"></i>
                <h5 class="mt-2"><%= nCitas %> citas</h5>
                <a href="mis_citas.jsp" class="text-white">Ver citas</a>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-3">
        <div class="card text-bg-dark shadow-sm h-100">
            <div class="card-body">
                <i class="bi bi-file-earmark-text display-4"></i>
                <h5 class="mt-2"><%= nSolic %> solicitudes</h5>
                <a href="mis_solicitudes.jsp" class="text-white">Ver trámites</a>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-3">
        <div class="card text-bg-secondary shadow-sm h-100">
            <div class="card-body">
                <i class="bi bi-chat-dots display-4"></i>
                <h5 class="mt-2"><%= nMsj %> mensajes <% if (nMsj > 0) { %><span class="badge rounded-pill text-bg-danger ms-1"><%= nMsj %> nuevos</span><% } %></h5>
                <a href="mensajes.jsp" class="text-white">Ver mensajes</a>
            </div>
        </div>
    </div>
</div>

<div class="row g-4 mt-1">
    <div class="col-12 col-md-6">
        <div class="card shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold"><i class="bi bi-search"></i> Buscar propiedades</h6>
                <p class="text-muted small">Encuentra el inmueble ideal por ciudad, tipo y precio.</p>
                <a href="../buscar.jsp" class="btn btn-outline-primary btn-sm">Ir al catálogo</a>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-6">
        <div class="card shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold"><i class="bi bi-person-badge"></i> Mi perfil</h6>
                <p class="text-muted small">Actualiza tu documento, teléfono y dirección.</p>
                <a href="perfil.jsp" class="btn btn-outline-primary btn-sm">Editar perfil</a>
            </div>
        </div>
    </div>
</div>

</main>
<footer class="footer-inmo py-3 text-center mt-auto">
    <span class="small">Inmobiliaria Arco Real &copy; 2026</span>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>