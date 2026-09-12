<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    int idPropSel = 0;
    try { idPropSel = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { idPropSel = 0; }
    Connection con = null;
    java.util.ArrayList<String[]> props = new java.util.ArrayList<String[]>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT p.id_propiedad, p.titulo_publicacion, c.nombre_ciudad FROM propiedad p " +
            "JOIN barrio b ON b.id_barrio=p.id_barrio JOIN ciudad c ON c.id_ciudad=b.id_ciudad " +
            "WHERE p.estado='Disponible' ORDER BY p.titulo_publicacion");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) props.add(new String[]{String.valueOf(rs.getInt(1)), rs.getString(2), rs.getString(3)});
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Radicar Solicitud";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<div class="card shadow-sm mx-auto" style="max-width:720px">
    <div class="card-body p-4">
        <h5 class="fw-bold mb-1"><i class="bi bi-file-earmark-arrow-up"></i> Radicar solicitud de compra o arriendo</h5>
        <p class="text-muted small mb-4">Adjunta los documentos requeridos (cédula, certificados, etc.). Máximo 4 archivos de hasta 5&nbsp;MB.</p>

        <form method="POST" action="controlador_solicitud.jsp" enctype="multipart/form-data">
            <div class="mb-3">
                <label class="form-label">Propiedad *</label>
                <%
                    if (idPropSel > 0) {
                        String tit = "";
                        for (String[] p : props) if (Integer.parseInt(p[0]) == idPropSel) tit = p[1] + " (" + p[2] + ")";
                %>
                    <input type="hidden" name="id_propiedad" value="<%= idPropSel %>">
                    <input type="text" class="form-control" value="<%= tit %>" disabled>
                <% } else { %>
                    <select name="id_propiedad" class="form-select" required>
                        <option value="">Seleccione una propiedad disponible</option>
                        <% for (String[] p : props) { %>
                            <option value="<%= p[0] %>"><%= p[1] %> (<%= p[2] %>)</option>
                        <% } %>
                    </select>
                <% } %>
            </div>
            <div class="mb-3">
                <label class="form-label">Tipo de trámite *</label>
                <select name="tipo_tramite" class="form-select" required>
                    <option value="">Seleccione...</option>
                    <option value="Compra">Compra</option>
                    <option value="Arriendo">Arriendo</option>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Documentos a radicar</label>
                <div class="row g-2" id="filaDocs">
                    <div class="col-12"><input type="file" name="documentos" class="form-control" accept=".pdf,.jpg,.jpeg,.png"></div>
                    <div class="col-12"><input type="file" name="documentos" class="form-control" accept=".pdf,.jpg,.jpeg,.png"></div>
                    <div class="col-12"><input type="file" name="documentos" class="form-control" accept=".pdf,.jpg,.jpeg,.png"></div>
                </div>
                <button type="button" class="btn btn-sm btn-outline-secondary mt-2" onclick="agregarInputFile()"><i class="bi bi-plus-circle"></i> Agregar otro archivo</button>
            </div>
            <div class="d-grid">
                <button class="btn btn-success" type="submit"><i class="bi bi-send"></i> Enviar solicitud</button>
            </div>
        </form>
    </div>
</div>

<script>
    function agregarInputFile() {
        var fila = document.getElementById('filaDocs');
        if (fila.querySelectorAll('input[type=file]').length >= 4) { alert('Máximo 4 archivos'); return; }
        var div = document.createElement('div');
        div.className = 'col-12';
        div.innerHTML = '<input type="file" name="documentos" class="form-control" accept=".pdf,.jpg,.jpeg,.png">';
        fila.appendChild(div);
    }
</script>

</main>
<footer class="footer-inmo py-3 text-center mt-auto">
    <span class="small"><a class="text-white" href="index.jsp">Volver al panel</a></span>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>