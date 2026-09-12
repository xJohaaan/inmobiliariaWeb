<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    Connection con = null;
    java.util.ArrayList<String[]> citas = new java.util.ArrayList<String[]>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT c.id_cita, p.titulo_publicacion, c.fecha_hora, c.estado, c.id_propiedad " +
            "FROM cita c JOIN propiedad p ON p.id_propiedad=c.id_propiedad " +
            "WHERE c.id_usuario=? ORDER BY c.fecha_hora DESC");
        ps.setInt(1, idUsr);
        ResultSet rs = ps.executeQuery();
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
        while (rs.next()) {
            citas.add(new String[]{String.valueOf(rs.getInt("id_cita")), rs.getString("titulo_publicacion"),
                    sdf.format(rs.getTimestamp("fecha_hora")), rs.getString("estado"),
                    String.valueOf(rs.getInt("id_propiedad"))});
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Mis Citas";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<%
    String flash = (String) session.getAttribute("flashCita");
    if (flash != null) { session.removeAttribute("flashCita"); %>
    <div class="alert alert-info"><%= flash %></div>
<% } %>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead><tr><th>#</th><th>Propiedad</th><th>Fecha</th><th>Estado</th><th></th></tr></thead>
                <tbody>
                <% for (String[] c : citas) {
                    String badge = c[3].equals("Pendiente") ? "warning" : c[3].equals("Aprobada") ? "success" : "danger";
                %>
                    <tr>
                        <td><%= c[0] %></td>
                        <td><a href="../propiedad.jsp?id=<%= c[4] %>"><%= c[1] %></a></td>
                        <td><%= c[2] %></td>
                        <td><span class="badge text-bg-<%= badge %>"><%= c[3] %></span></td>
                        <td></td>
                    </tr>
                <% } %>
                <% if (citas.isEmpty()) { %>
                    <tr><td colspan="5" class="text-center text-muted">No has agendado citas todavía. Busca una propiedad y agenda tu visita.</td></tr>
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