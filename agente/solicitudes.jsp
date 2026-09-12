<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null;
    java.util.ArrayList<String[]> sols = new java.util.ArrayList<String[]>();
    java.util.HashMap<String, java.util.ArrayList<String>> docs = new java.util.HashMap<String, java.util.ArrayList<String>>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT s.id_solicitud, p.titulo_publicacion, u.correo, s.tipo_tramite, s.estado, s.fecha_solicitud, p.id_propiedad " +
            "FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad " +
            "JOIN usuario u ON u.id_usuario=s.id_usuario ORDER BY (s.estado='En revisión') DESC, s.fecha_solicitud ASC");
        ResultSet rs = ps.executeQuery();
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        while (rs.next()) {
            String idSol = String.valueOf(rs.getInt("id_solicitud"));
            sols.add(new String[]{idSol, rs.getString("titulo_publicacion"), rs.getString("correo"),
                    rs.getString("tipo_tramite"), rs.getString("estado"), sdf.format(rs.getTimestamp("fecha_solicitud")),
                    String.valueOf(rs.getInt("id_propiedad"))});
        }
        rs.close(); ps.close();

        PreparedStatement psDoc = con.prepareStatement("SELECT id_solicitud, nombre_documento, ruta_archivo FROM documento_solicitud ORDER BY id_documento");
        ResultSet rsDoc = psDoc.executeQuery();
        while (rsDoc.next()) {
            String idSol = String.valueOf(rsDoc.getInt(1));
            if (!docs.containsKey(idSol)) docs.put(idSol, new java.util.ArrayList<String>());
            docs.get(idSol).add(rsDoc.getString(2) + "|" + rsDoc.getString(3));
        }
        rsDoc.close(); psDoc.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Solicitudes y Documentación";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<%
    String flash = (String) session.getAttribute("flashSolicAg");
    if (flash != null) { session.removeAttribute("flashSolicAg"); %>
    <div class="alert alert-info"><%= flash %></div>
<% } %>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead><tr><th>#</th><th>Propiedad</th><th>Cliente</th><th>Trámite</th><th>Fecha</th><th>Estado</th><th>Documentos</th><th>Acciones</th></tr></thead>
                <tbody>
                <% for (String[] s : sols) {
                    String badge = s[4].equals("Aprobada") ? "success" : s[4].equals("Rechazada") ? "danger" : "warning";
                    String idSol = s[0];
                %>
                    <tr>
                        <td><%= idSol %></td>
                        <td><%= s[1] %></td>
                        <td><%= s[2] %></td>
                        <td><%= s[3] %></td>
                        <td><%= s[5] %></td>
                        <td><span class="badge text-bg-<%= badge %>"><%= s[4] %></span></td>
                        <td>
                            <% java.util.ArrayList<String> d = docs.get(idSol);
                               if (d != null) { for (String x : d) {
                                   String[] parts = x.split("\\|", 2);
                            %>
                                <span class="badge text-bg-secondary"><a class="text-white" href="../<%= parts[1] %>" target="_blank"><i class="bi bi-file-earmark"></i> <%= parts[0] %></a></span>
                            <% } } %>
                        </td>
                        <td class="text-nowrap">
                            <% if (s[4].equals("En revisión")) { %>
                                <a class="btn btn-sm btn-success" href="controlador_solicitud.jsp?accion=aprobar&id=<%= idSol %>"><i class="bi bi-check-lg"></i> Aprobar</a>
                                <a class="btn btn-sm btn-danger" href="controlador_solicitud.jsp?accion=rechazar&id=<%= idSol %>"><i class="bi bi-x-lg"></i> Rechazar</a>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
                <% if (sols.isEmpty()) { %>
                    <tr><td colspan="8" class="text-center text-muted">No hay solicitudes registradas.</td></tr>
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