<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    int nProps = 0, nCitPend = 0, nSolicRev = 0;
    Connection con = null;
    try {
        con = obtenerConexion();
        PreparedStatement p1 = con.prepareStatement("SELECT COUNT(*) FROM propiedad WHERE estado<>'De_baja'");
        ResultSet r1 = p1.executeQuery(); if (r1.next()) nProps = r1.getInt(1); r1.close(); p1.close();
        PreparedStatement p2 = con.prepareStatement("SELECT COUNT(*) FROM cita WHERE estado='Pendiente'");
        ResultSet r2 = p2.executeQuery(); if (r2.next()) nCitPend = r2.getInt(1); r2.close(); p2.close();
        PreparedStatement p3 = con.prepareStatement("SELECT COUNT(*) FROM solicitud WHERE estado='En revisión'");
        ResultSet r3 = p3.executeQuery(); if (r3.next()) nSolicRev = r3.getInt(1); r3.close(); p3.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Panel de la Inmobiliaria (Agente)";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<div class="row g-4">
    <div class="col-12 col-md-4">
        <div class="card text-bg-primary shadow-sm h-100">
            <div class="card-body">
                <i class="bi bi-building display-4"></i>
                <h5 class="mt-2"><%= nProps %> propiedades activas</h5>
                <a href="mis_propiedades.jsp" class="text-white">Gestionar propiedades</a>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-4">
        <div class="card text-bg-warning shadow-sm h-100">
            <div class="card-body">
                <i class="bi bi-calendar-week display-4"></i>
                <h5 class="mt-2"><%= nCitPend %> citas pendientes</h5>
                <a href="citas.jsp" class="text-white">Atender citas</a>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-4">
        <div class="card text-bg-info shadow-sm h-100">
            <div class="card-body">
                <i class="bi bi-inboxes display-4"></i>
                <h5 class="mt-2"><%= nSolicRev %> solicitudes en revisión</h5>
                <a href="solicitudes.jsp" class="text-white">Revisar solicitudes</a>
            </div>
        </div>
    </div>
</div>

<div class="row g-4 mt-1">
    <div class="col-12 col-md-4">
        <div class="card shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold"><i class="bi bi-plus-square"></i> Publicar propiedad</h6>
                <p class="text-muted small">Registra un nuevo inmueble con fotos y características.</p>
                <a href="form_propiedad.jsp" class="btn btn-outline-primary btn-sm">Nueva propiedad</a>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-4">
        <div class="card shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold"><i class="bi bi-folder-check"></i> Revisar documentos</h6>
                <p class="text-muted small">Aprueba o rechaza la documentación de los clientes.</p>
                <a href="solicitudes.jsp" class="btn btn-outline-primary btn-sm">Ir a solicitudes</a>
            </div>
        </div>
    </div>
    <div class="col-12 col-md-4">
        <div class="card shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold"><i class="bi bi-graph-up"></i> Reportes</h6>
                <p class="text-muted small">Consulta propiedades por ciudad, citas y solicitudes.</p>
                <a href="reportes.jsp" class="btn btn-outline-primary btn-sm">Ver reportes</a>
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