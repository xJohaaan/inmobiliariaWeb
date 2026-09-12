<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"admin"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null;
    java.util.ArrayList<String[]> logs = new java.util.ArrayList<String[]>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT a.id_auditoria, a.accion_realizada, a.fecha_hora, COALESCE(u.correo, '(sin sesión)') AS correo " +
            "FROM auditoria a LEFT JOIN usuario u ON u.id_usuario=a.id_usuario ORDER BY a.fecha_hora DESC LIMIT 200");
        ResultSet rs = ps.executeQuery();
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss a");
        while (rs.next()) {
            logs.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2), sdf.format(rs.getTimestamp("fecha_hora")), rs.getString("correo")});
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Auditoría de la Aplicación";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead><tr><th>#</th><th>Usuario</th><th>Acción</th><th>Fecha/Hora</th></tr></thead>
                <tbody>
                <% for (String[] l : logs) { %>
                    <tr><td><%= l[0] %></td><td><%= l[3] %></td><td><%= l[1] %></td><td><%= l[2] %></td></tr>
                <% } %>
                <% if (logs.isEmpty()) { %>
                    <tr><td colspan="4" class="text-center text-muted">Sin registros de auditoría.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

</main>
<footer class="footer-inmo py-3 text-center mt-auto">
    <span class="small"><a class="text-white" href="index.jsp">Volver al panel</a></span>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>