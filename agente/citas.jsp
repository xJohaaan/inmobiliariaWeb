<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null;
    java.util.ArrayList<String[]> citas = new java.util.ArrayList<String[]>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT c.id_cita, c.fecha_hora, c.estado, p.titulo_publicacion, u.correo, p.id_propiedad " +
            "FROM cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad " +
            "JOIN usuario u ON u.id_usuario=c.id_usuario " +
            "ORDER BY (c.estado='Pendiente') DESC, c.fecha_hora ASC");
        ResultSet rs = ps.executeQuery();
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
        while (rs.next()) {
            citas.add(new String[]{String.valueOf(rs.getInt("id_cita")), sdf.format(rs.getTimestamp("fecha_hora")),
                    rs.getString("estado"), rs.getString("titulo_publicacion"), rs.getString("correo"),
                    String.valueOf(rs.getInt("id_propiedad"))});
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Citas de Visita";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<%
    String flash = (String) session.getAttribute("flashCitaAg");
    if (flash != null) { session.removeAttribute("flashCitaAg"); %>
    <div class="alert alert-info"><%= flash %></div>
<% } %>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead><tr><th>#</th><th>Propiedad</th><th>Cliente</th><th>Fecha</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                <% for (String[] c : citas) {
                    String badge = c[2].equals("Pendiente") ? "warning" : c[2].equals("Aprobada") ? "success" : "danger";
                %>
                    <tr>
                        <td><%= c[0] %></td>
                        <td><a href="mis_propiedades.jsp"><%= c[3] %></a> <small class="text-muted">(id <%= c[5] %>)</small></td>
                        <td><%= c[4] %></td>
                        <td><%= c[1] %></td>
                        <td><span class="badge text-bg-<%= badge %>"><%= c[2] %></span></td>
                        <td class="text-nowrap">
                            <% if (c[2].equals("Pendiente")) { %>
                                <a class="btn btn-sm btn-success" href="controlador_cita.jsp?accion=aprobar&id=<%= c[0] %>"><i class="bi bi-check-lg"></i> Aprobar</a>
                                <a class="btn btn-sm btn-danger" href="controlador_cita.jsp?accion=rechazar&id=<%= c[0] %>"><i class="bi bi-x-lg"></i> Rechazar</a>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
                <% if (citas.isEmpty()) { %>
                    <tr><td colspan="6" class="text-center text-muted">No hay citas registradas.</td></tr>
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