<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"admin"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null;
    java.util.ArrayList<String[]> usuarios = new java.util.ArrayList<String[]>();
    java.util.HashMap<Integer, java.util.ArrayList<String>> rolesMap = new java.util.HashMap<Integer, java.util.ArrayList<String>>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT u.id_usuario, u.correo, u.estado, COALESCE(CONCAT(p.nombres, ' ', p.apellidos), '(sin perfil)') AS nombre " +
            "FROM usuario u LEFT JOIN perfil p ON p.id_usuario=u.id_usuario ORDER BY u.id_usuario");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            usuarios.add(new String[]{String.valueOf(rs.getInt("id_usuario")), rs.getString("correo"),
                    rs.getString("estado"), rs.getString("nombre")});
        }
        rs.close(); ps.close();

        PreparedStatement psR = con.prepareStatement(
            "SELECT ur.id_usuario, r.nombre FROM usuario_rol ur JOIN rol r ON r.id_rol=ur.id_rol");
        ResultSet rsR = psR.executeQuery();
        while (rsR.next()) {
            int idU = rsR.getInt(1);
            if (!rolesMap.containsKey(idU)) rolesMap.put(idU, new java.util.ArrayList<String>());
            rolesMap.get(idU).add(rsR.getString(2).toLowerCase());
        }
        rsR.close(); psR.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Gestión de Usuarios y Roles";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<%
    String flash = (String) session.getAttribute("flashAdmin");
    if (flash != null) { session.removeAttribute("flashAdmin"); %>
    <div class="alert alert-info"><%= flash %></div>
<% } %>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped align-middle">
                <thead><tr><th>ID</th><th>Correo</th><th>Nombre</th><th>Estado</th><th style="min-width:260px">Roles</th><th>Guardar</th></tr></thead>
                <tbody>
                <% for (String[] u : usuarios) {
                    int idU = Integer.parseInt(u[0]);
                    java.util.ArrayList<String> r = rolesMap.get(idU);
                    if (r == null) r = new java.util.ArrayList<String>();
                    boolean activa = u[2].equals("Activa");
                %>
                    <form method="POST" action="controlador_usuario.jsp">
                    <tr>
                        <td><%= idU %></td>
                        <td><%= u[1] %></td>
                        <td><%= u[3] %></td>
                        <td>
                            <span class="badge <%= activa ? "text-bg-success" : "text-bg-danger" %>"><%= u[2] %></span>
                            <select name="estado" class="form-select form-select-sm mt-1">
                                <option value="Activa" <%= activa ? "selected" : "" %>>Activa</option>
                                <option value="Inactiva" <%= !activa ? "selected" : "" %>>Inactiva</option>
                            </select>
                        </td>
                        <td>
                            <div class="d-flex gap-3">
                                <% String[][] rolesDef = {{"admin","Administrador"},{"agente","Agente"},{"cliente","Cliente"}};
                                   for (String[] rd : rolesDef) {
                                       boolean t = r.contains(rd[0]);
                                %>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="roles" value="<%= rd[0] %>" <%= t ? "checked" : "" %> id="rol_<%= idU %>_<%= rd[0] %>">
                                        <label class="form-check-label small" for="rol_<%= idU %>_<%= rd[0] %>"><%= rd[1] %></label>
                                    </div>
                                <% } %>
                            </div>
                        </td>
                        <td>
                            <input type="hidden" name="id" value="<%= idU %>">
                            <button class="btn btn-sm btn-outline-primary" type="submit"><i class="bi bi-save"></i> Guardar</button>
                        </td>
                    </tr>
                    </form>
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