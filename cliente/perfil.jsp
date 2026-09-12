<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    String n = "", ap = "", doc = "", tel = "", dir = "", foto = "";
    boolean existe = false;
    Connection con = null;
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement("SELECT nombres, apellidos, documento, telefono, direccion, foto FROM perfil WHERE id_usuario=?");
        ps.setInt(1, idUsr);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            existe = true;
            n = rs.getString("nombres"); if (n == null) n = "";
            ap = rs.getString("apellidos"); if (ap == null) ap = "";
            doc = rs.getString("documento"); if (doc == null) doc = "";
            tel = rs.getString("telefono"); if (tel == null) tel = "";
            dir = rs.getString("direccion"); if (dir == null) dir = "";
            foto = rs.getString("foto"); if (foto == null) foto = "";
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Mi Perfil";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<% 
    String flash = (String) session.getAttribute("flashPerfil");
    if (flash != null) { session.removeAttribute("flashPerfil"); %>
    <div class="alert alert-success"><%= flash %></div>
<% } %>

<div class="card shadow-sm mx-auto" style="max-width:640px">
    <div class="card-body p-4">
        <h5 class="fw-bold mb-4"><i class="bi bi-person-badge"></i> <%= existe ? "Editar mi perfil" : "Completar mi perfil" %></h5>
        <% if (existe && !foto.isEmpty()) { %>
            <img src="<%= foto %>" class="rounded-circle mb-3" style="width:90px;height:90px;object-fit:cover" alt="foto de perfil">
        <% } %>
        <form method="POST" action="controlador_perfil.jsp">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Nombres *</label>
                    <input type="text" name="nombres" class="form-control" value="<%= n %>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Apellidos *</label>
                    <input type="text" name="apellidos" class="form-control" value="<%= ap %>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Documento de identidad *</label>
                    <input type="text" name="documento" class="form-control" value="<%= doc %>" required pattern="[0-9.-]{6,20}" title="Solo números y guiones">
                </div>
                <div class="col-md-6">
                    <label class="form-label">Teléfono</label>
                    <input type="tel" name="telefono" class="form-control" value="<%= tel %>" pattern="[0-9+() -]{7,20}">
                </div>
                <div class="col-12">
                    <label class="form-label">Dirección</label>
                    <input type="text" name="direccion" class="form-control" value="<%= dir %>">
                </div>
                <div class="col-12">
                    <label class="form-label">URL de foto de perfil (opcional)</label>
                    <input type="url" name="foto" class="form-control" value="<%= foto %>">
                </div>
                <div class="col-12 d-grid">
                    <button class="btn btn-primary" type="submit"><i class="bi bi-save"></i> Guardar perfil</button>
                </div>
            </div>
        </form>
    </div>
</div>

</main>
<footer class="footer-inmo py-3 text-center mt-auto">
    <span class="small"><a class="text-white" href="index.jsp">Volver al panel</a></span>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>