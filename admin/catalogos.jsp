<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"admin"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null;
    java.util.ArrayList<String[]> ciudades = new java.util.ArrayList<String[]>();
    java.util.ArrayList<String[]> barrios = new java.util.ArrayList<String[]>();
    java.util.ArrayList<String[]> tipos = new java.util.ArrayList<String[]>();
    java.util.ArrayList<String[]> caracs = new java.util.ArrayList<String[]>();
    java.util.ArrayList<String[]> inmos = new java.util.ArrayList<String[]>();
    try {
        con = obtenerConexion();
        ResultSet r = con.createStatement().executeQuery("SELECT id_ciudad, nombre_ciudad FROM ciudad ORDER BY nombre_ciudad");
        while (r.next()) ciudades.add(new String[]{String.valueOf(r.getInt(1)), r.getString(2)}); r.close();
        r = con.createStatement().executeQuery("SELECT b.id_barrio, b.nombre_barrio, b.estrato, c.nombre_ciudad FROM barrio b JOIN ciudad c ON c.id_ciudad=b.id_ciudad ORDER BY c.nombre_ciudad, b.nombre_barrio");
        while (r.next()) barrios.add(new String[]{String.valueOf(r.getInt(1)), r.getString(2), r.getString(3), r.getString(4)}); r.close();
        r = con.createStatement().executeQuery("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
        while (r.next()) tipos.add(new String[]{String.valueOf(r.getInt(1)), r.getString(2)}); r.close();
        r = con.createStatement().executeQuery("SELECT id_caracteristica, nombre FROM caracteristica ORDER BY id_caracteristica");
        while (r.next()) caracs.add(new String[]{String.valueOf(r.getInt(1)), r.getString(2)}); r.close();
        r = con.createStatement().executeQuery("SELECT id_inmobiliaria, nit, nombre_empresa, telefono, correo_contacto FROM inmobiliaria ORDER BY nombre_empresa");
        while (r.next()) inmos.add(new String[]{String.valueOf(r.getInt(1)), r.getString(2), r.getString(3), r.getString(4), r.getString(5)}); r.close();
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }
    String __tituloPanel = "Catálogos del Sistema";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<%
    String flash = (String) session.getAttribute("flashCat");
    if (flash != null) { session.removeAttribute("flashCat"); %>
    <div class="alert alert-info"><%= flash %></div>
<% } %>

<div class="row g-4">
    <div class="col-lg-6">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-bold"><i class="bi bi-geo-alt"></i> Ciudades</div>
            <div class="card-body">
                <form method="POST" action="controlador_catalogo.jsp" class="input-group mb-3">
                    <input type="hidden" name="accion" value="agregar"><input type="hidden" name="entidad" value="ciudad">
                    <input type="text" name="nombre" class="form-control" placeholder="Nombre de la ciudad" required>
                    <button class="btn btn-outline-primary" type="submit"><i class="bi bi-plus"></i></button>
                </form>
                <ul class="list-group">
                    <% for (String[] c : ciudades) { %>
                        <li class="list-group-item d-flex justify-content-between">
                            <span><%= c[1] %></span>
                            <a href="controlador_catalogo.jsp?accion=eliminar&entidad=ciudad&id=<%= c[0] %>" class="text-danger"><i class="bi bi-x-circle"></i></a>
                        </li>
                    <% } %>
                </ul>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-bold"><i class="bi bi-signpost"></i> Barrios</div>
            <div class="card-body">
                <form method="POST" action="controlador_catalogo.jsp" class="row g-2 mb-3">
                    <input type="hidden" name="accion" value="agregar"><input type="hidden" name="entidad" value="barrio">
                    <div class="col-5"><select name="id_ciudad" class="form-select" required>
                        <option value="">Ciudad</option>
                        <% for (String[] c : ciudades) { %><option value="<%= c[0] %>"><%= c[1] %></option><% } %>
                    </select></div>
                    <div class="col-4"><input type="text" name="nombre" class="form-control" placeholder="Barrio" required></div>
                    <div class="col-2"><input type="number" name="estrato" class="form-control" placeholder="Estrato" min="1" max="6" required></div>
                    <div class="col-1 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-plus"></i></button></div>
                </form>
                <div class="table-responsive"><table class="table table-sm">
                    <thead><tr><th>Barrio</th><th>Ciudad</th><th>Estrato</th><th></th></tr></thead>
                    <tbody>
                    <% for (String[] b : barrios) { %>
                        <tr><td><%= b[1] %></td><td><%= b[3] %></td><td><%= b[2] %></td>
                            <td><a href="controlador_catalogo.jsp?accion=eliminar&entidad=barrio&id=<%= b[0] %>" class="text-danger"><i class="bi bi-x-circle"></i></a></td></tr>
                    <% } %>
                    </tbody>
                </table></div>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-bold"><i class="bi bi-tags"></i> Tipos de propiedad</div>
            <div class="card-body">
                <form method="POST" action="controlador_catalogo.jsp" class="input-group mb-3">
                    <input type="hidden" name="accion" value="agregar"><input type="hidden" name="entidad" value="tipo">
                    <input type="text" name="nombre" class="form-control" placeholder="Ej: Apartamento" required>
                    <button class="btn btn-outline-primary" type="submit"><i class="bi bi-plus"></i></button>
                </form>
                <ul class="list-group">
                    <% for (String[] t : tipos) { %>
                        <li class="list-group-item d-flex justify-content-between"><span><%= t[1] %></span>
                            <a href="controlador_catalogo.jsp?accion=eliminar&entidad=tipo&id=<%= t[0] %>" class="text-danger"><i class="bi bi-x-circle"></i></a></li>
                    <% } %>
                </ul>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card shadow-sm h-100">
            <div class="card-header fw-bold"><i class="bi bi-list-check"></i> Características</div>
            <div class="card-body">
                <form method="POST" action="controlador_catalogo.jsp" class="input-group mb-3">
                    <input type="hidden" name="accion" value="agregar"><input type="hidden" name="entidad" value="caracteristica">
                    <input type="text" name="nombre" class="form-control" placeholder="Ej: Piscina" required>
                    <button class="btn btn-outline-primary" type="submit"><i class="bi bi-plus"></i></button>
                </form>
                <ul class="list-group">
                    <% for (String[] c : caracs) { %>
                        <li class="list-group-item d-flex justify-content-between"><span><%= c[1] %></span>
                            <a href="controlador_catalogo.jsp?accion=eliminar&entidad=caracteristica&id=<%= c[0] %>" class="text-danger"><i class="bi bi-x-circle"></i></a></li>
                    <% } %>
                </ul>
            </div>
        </div>
    </div>
    <div class="col-12">
        <div class="card shadow-sm">
            <div class="card-header fw-bold"><i class="bi bi-buildings"></i> Inmobiliarias</div>
            <div class="card-body">
                <form method="POST" action="controlador_catalogo.jsp" class="row g-2 mb-3">
                    <input type="hidden" name="accion" value="agregar"><input type="hidden" name="entidad" value="inmobiliaria">
                    <div class="col-md-2"><input type="text" name="nit" class="form-control" placeholder="NIT" required></div>
                    <div class="col-md-3"><input type="text" name="nombre" class="form-control" placeholder="Nombre" required></div>
                    <div class="col-md-2"><input type="text" name="telefono" class="form-control" placeholder="Teléfono"></div>
                    <div class="col-md-3"><input type="email" name="correo" class="form-control" placeholder="Correo de contacto"></div>
                    <div class="col-md-2 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-plus"></i> Agregar</button></div>
                </form>
                <div class="table-responsive"><table class="table table-sm table-striped">
                    <thead><tr><th>NIT</th><th>Nombre</th><th>Teléfono</th><th>Correo</th><th></th></tr></thead>
                    <tbody>
                    <% for (String[] i : inmos) { %>
                        <tr><td><%= i[1] %></td><td><%= i[2] %></td><td><%= i[3] %></td><td><%= i[4] %></td>
                            <td><a href="controlador_catalogo.jsp?accion=eliminar&entidad=inmobiliaria&id=<%= i[0] %>" class="text-danger"><i class="bi bi-x-circle"></i></a></td></tr>
                    <% } %>
                    </tbody>
                </table></div>
            </div>
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