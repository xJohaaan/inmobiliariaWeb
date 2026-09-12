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
    java.util.ArrayList<String[]> solicitudes = new java.util.ArrayList<String[]>();
    java.util.HashMap<String, java.util.ArrayList<String>> docs = new java.util.HashMap<String, java.util.ArrayList<String>>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT s.id_solicitud, p.titulo_publicacion, s.tipo_tramite, s.estado, s.fecha_solicitud, s.id_propiedad " +
            "FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad " +
            "WHERE s.id_usuario=? ORDER BY s.fecha_solicitud DESC");
        ps.setInt(1, idUsr);
        ResultSet rs = ps.executeQuery();
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        while (rs.next()) {
            String idSol = String.valueOf(rs.getInt("id_solicitud"));
            solicitudes.add(new String[]{idSol, rs.getString("titulo_publicacion"), rs.getString("tipo_tramite"),
                    rs.getString("estado"), sdf.format(rs.getTimestamp("fecha_solicitud")), String.valueOf(rs.getInt("id_propiedad"))});
        }
        rs.close(); ps.close();

        PreparedStatement psDoc = con.prepareStatement("SELECT id_solicitud, nombre_documento FROM documento_solicitud");
        ResultSet rsDoc = psDoc.executeQuery();
        while (rsDoc.next()) {
            String idSol = String.valueOf(rsDoc.getInt(1));
            if (!docs.containsKey(idSol)) docs.put(idSol, new java.util.ArrayList<String>());
            docs.get(idSol).add(rsDoc.getString(2));
        }
        rsDoc.close(); psDoc.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Mis Solicitudes y Trámites";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<%
    String flash = (String) session.getAttribute("flashSolicitud");
    if (flash != null) { session.removeAttribute("flashSolicitud"); %>
    <div class="alert alert-<%= flash.contains("Error") ? "danger" : "success" %>"><%= flash %></div>
<% } %>

<div class="d-flex justify-content-end mb-3">
    <a href="radicar_solicitud.jsp" class="btn btn-success"><i class="bi bi-plus-circle"></i> Radicar nueva solicitud</a>
</div>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead><tr><th>#</th><th>Propiedad</th><th>Trámite</th><th>Fecha</th><th>Estado</th><th>Documentos</th></tr></thead>
                <tbody>
                <% for (String[] s : solicitudes) {
                    String badge = s[3].equals("Aprobada") ? "success" : s[3].equals("Rechazada") ? "danger" : "warning";
                    java.util.ArrayList<String> d = docs.get(s[0]);
                %>
                    <tr>
                        <td><%= s[0] %></td>
                        <td><a href="../propiedad.jsp?id=<%= s[5] %>"><%= s[1] %></a></td>
                        <td><%= s[2] %></td>
                        <td><%= s[4] %></td>
                        <td><span class="badge text-bg-<%= badge %>"><%= s[3] %></span></td>
                        <td>
                            <% if (d != null) { for (String nom : d) { %> <span class="badge text-bg-secondary"><i class="bi bi-file-earmark"></i> <%= nom %></span> <% } } %>
                        </td>
                    </tr>
                <% } %>
                <% if (solicitudes.isEmpty()) { %>
                    <tr><td colspan="6" class="text-center text-muted">No has radicado solicitudes. Elige una propiedad y hazlo desde su ficha.</td></tr>
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