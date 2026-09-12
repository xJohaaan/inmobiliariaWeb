<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"admin"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    int nUsr = 0, nAct = 0, nProp = 0, nAud = 0;
    Connection con = null;
    try {
        con = obtenerConexion();
        PreparedStatement p1 = con.prepareStatement("SELECT COUNT(*) AS t, SUM(estado='Activa') AS a FROM usuario");
        ResultSet r1 = p1.executeQuery(); if (r1.next()) { nUsr = r1.getInt(1); nAct = r1.getInt(2); } r1.close(); p1.close();
        PreparedStatement p2 = con.prepareStatement("SELECT COUNT(*) FROM propiedad");
        ResultSet r2 = p2.executeQuery(); if (r2.next()) nProp = r2.getInt(1); r2.close(); p2.close();
        PreparedStatement p3 = con.prepareStatement("SELECT COUNT(*) FROM auditoria");
        ResultSet r3 = p3.executeQuery(); if (r3.next()) nAud = r3.getInt(1); r3.close(); p3.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Panel de Administración";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<div class="row g-4">
    <div class="col-12 col-md-3">
        <div class="card text-bg-primary shadow-sm h-100"><div class="card-body">
            <i class="bi bi-people display-4"></i>
            <h5 class="mt-2"><%= nUsr %> usuarios (<%= nAct %> activos)</h5>
            <a href="usuarios.jsp" class="text-white">Gestionar usuarios y roles</a>
        </div></div>
    </div>
    <div class="col-12 col-md-3">
        <div class="card text-bg-secondary shadow-sm h-100"><div class="card-body">
            <i class="bi bi-building display-4"></i>
            <h5 class="mt-2"><%= nProp %> propiedades</h5>
            <a href="catalogos.jsp" class="text-white">Parametrizar catálogos</a>
        </div></div>
    </div>
    <div class="col-12 col-md-3">
        <div class="card text-bg-dark shadow-sm h-100"><div class="card-body">
            <i class="bi bi-journal-text display-4"></i>
            <h5 class="mt-2"><%= nAud %> registros de auditoría</h5>
            <a href="auditoria.jsp" class="text-white">Ver auditoría</a>
        </div></div>
    </div>
    <div class="col-12 col-md-3">
        <div class="card text-bg-success shadow-sm h-100"><div class="card-body">
            <i class="bi bi-speedometer2 display-4"></i>
            <h5 class="mt-2">Visión general</h5>
            <a href="catalogos.jsp" class="text-white">Configurar sistema</a>
        </div></div>
    </div>
</div>

</main>
<footer class="footer-inmo py-3 text-center mt-auto">
    <span class="small">Administración &copy; 2026</span>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>