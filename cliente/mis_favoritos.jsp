<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Locale" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    Connection con = null;
    java.util.ArrayList<Integer> ids = new java.util.ArrayList<Integer>();
    java.util.ArrayList<String> titulos = new java.util.ArrayList<String>();
    java.util.ArrayList<String> ubi = new java.util.ArrayList<String>();
    java.util.ArrayList<Double> precios = new java.util.ArrayList<Double>();
    java.util.ArrayList<String> imgs = new java.util.ArrayList<String>();
    try {
        con = obtenerConexion();
        PreparedStatement ps = con.prepareStatement(
            "SELECT p.id_propiedad, p.titulo_publicacion, p.precio, b.nombre_barrio, c.nombre_ciudad, " +
            "(SELECT url_ruta_imagen FROM imagen_propiedad i WHERE i.id_propiedad=p.id_propiedad LIMIT 1) AS img " +
            "FROM favorito f JOIN propiedad p ON p.id_propiedad=f.id_propiedad " +
            "JOIN barrio b ON b.id_barrio=p.id_barrio JOIN ciudad c ON c.id_ciudad=b.id_ciudad " +
            "WHERE f.id_usuario=? ORDER BY f.id_favorito DESC");
        ps.setInt(1, idUsr);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            ids.add(rs.getInt("id_propiedad"));
            titulos.add(rs.getString("titulo_publicacion"));
            ubi.add(rs.getString("nombre_barrio") + ", " + rs.getString("nombre_ciudad"));
            precios.add(rs.getDouble("precio"));
            String img = rs.getString("img");
            imgs.add(img != null ? img : "https://picsum.photos/seed/none/900/600");
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Mis Favoritos";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<%
    String flash = (String) session.getAttribute("flashFav");
    if (flash != null) { session.removeAttribute("flashFav"); %>
    <div class="alert alert-info"><%= flash %></div>
<% } %>

<div class="row g-4">
    <% for (int i = 0; i < ids.size(); i++) { %>
        <div class="col-12 col-md-6 col-xl-4">
            <div class="card h-100 shadow-sm card-propiedad">
                <img src="<%= imgs.get(i) %>" class="card-img-top img-card" alt="<%= titulos.get(i) %>">
                <div class="card-body">
                    <h6 class="card-title fw-bold"><%= titulos.get(i) %></h6>
                    <p class="text-muted small mb-1"><i class="bi bi-geo-alt"></i> <%= ubi.get(i) %></p>
                    <p class="precio">$ <%= String.format(Locale.US, "%,.0f", precios.get(i)) %></p>
                    <div class="d-flex gap-2">
                        <a href="../propiedad.jsp?id=<%= ids.get(i) %>" class="btn btn-sm btn-primary">Ver ficha</a>
                        <a href="controlador_favorito.jsp?id=<%= ids.get(i) %>&accion=panel" class="btn btn-sm btn-outline-danger"><i class="bi bi-heartbreak"></i> Quitar</a>
                    </div>
                </div>
            </div>
        </div>
    <% } %>
    <% if (ids.isEmpty()) { %>
        <div class="col-12"><div class="alert alert-info">Aún no tienes favoritos. <a href="../buscar.jsp">Explora el catálogo</a>.</div></div>
    <% } %>
</div>

</main>
<footer class="footer-inmo py-3 text-center mt-auto">
    <span class="small"><a class="text-white" href="index.jsp">Volver al panel</a></span>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>