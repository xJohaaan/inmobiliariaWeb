<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Locale" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null;
    java.util.ArrayList<String[]> props = new java.util.ArrayList<String[]>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT p.id_propiedad, p.titulo_publicacion, p.matricula_inmobiliaria, p.precio, p.estado, " +
            "b.nombre_barrio, c.nombre_ciudad FROM propiedad p " +
            "JOIN barrio b ON b.id_barrio=p.id_barrio JOIN ciudad c ON c.id_ciudad=b.id_ciudad " +
            "WHERE p.estado<>'De_baja' ORDER BY p.id_propiedad DESC");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            props.add(new String[]{String.valueOf(rs.getInt("id_propiedad")), rs.getString("titulo_publicacion"),
                    rs.getString("matricula_inmobiliaria"), String.format(Locale.US, "%,.0f", rs.getDouble("precio")),
                    rs.getString("estado"), rs.getString("nombre_barrio") + ", " + rs.getString("nombre_ciudad")});
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Mis Propiedades";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<%
    String flash = (String) session.getAttribute("flashProp");
    if (flash != null) { session.removeAttribute("flashProp"); %>
    <div class="alert alert-<%= flash.contains("Error") ? "danger" : "success" %>"><%= flash %></div>
<% } %>

<div class="d-flex justify-content-end mb-3">
    <a href="form_propiedad.jsp" class="btn btn-primary"><i class="bi bi-plus-circle"></i> Nueva propiedad</a>
</div>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead><tr><th>ID</th><th>Título</th><th>Matrícula</th><th>Ubicación</th><th>Precio</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                <% for (String[] p : props) {
                    String badge = p[4].equals("Disponible") ? "success" : p[4].equals("Vendido") ? "primary" : p[4].equals("Alquilado") ? "info" : "secondary";
                %>
                    <tr>
                        <td><%= p[0] %></td>
                        <td><%= p[1] %></td>
                        <td><%= p[2] %></td>
                        <td><%= p[5] %></td>
                        <td>$ <%= p[3] %></td>
                        <td><span class="badge text-bg-<%= badge %>"><%= p[4] %></span></td>
                        <td class="text-nowrap">
                            <a href="form_propiedad.jsp?id=<%= p[0] %>" class="btn btn-sm btn-outline-primary"><i class="bi bi-pencil"></i> Editar</a>
                            <% if (!p[4].equals("De_baja")) { %>
                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="darBaja(<%= p[0] %>)"><i class="bi bi-trash"></i> Baja</button>
                            <% } %>
                        </td>
                    </tr>
                <% } %>
                <% if (props.isEmpty()) { %>
                    <tr><td colspan="7" class="text-center text-muted">No hay propiedades. Crea la primera con el botón "Nueva propiedad".</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<form id="formBaja" method="POST" action="controlador_propiedad.jsp" class="d-none">
    <input type="hidden" name="accion" value="baja">
    <input type="hidden" name="id" id="bajaId">
</form>

<script>
    function darBaja(id) {
        if (confirm('¿Dar de baja esta propiedad? Dejará de mostrarse en el catálogo público.')) {
            document.getElementById('bajaId').value = id;
            document.getElementById('formBaja').submit();
        }
    }
</script>

</main>
<footer class="footer-inmo py-3 text-center mt-auto">
    <span class="small"><a class="text-white" href="index.jsp">Volver al panel</a></span>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>