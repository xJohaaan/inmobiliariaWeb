<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.DecimalFormat" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"admin"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null;
    // Consultas de agregacion: propiedades por ciudad y por estado
    java.util.LinkedHashMap<String, java.util.LinkedHashMap<String, Integer>> porCiudad =
            new java.util.LinkedHashMap<String, java.util.LinkedHashMap<String, Integer>>();
    java.util.ArrayList<String[]> porEstado = new java.util.ArrayList<String[]>(); // estado, cantidad, valor
    String[] estados = {"Disponible", "Alquilado", "Vendido", "De_baja"};
    int[] totalesEstado = {0, 0, 0, 0};
    int totalPropiedades = 0;
    double totalCartera = 0;

    try {
        con = obtenerConexion();

        ResultSet rs = con.createStatement().executeQuery(
            "SELECT c.nombre_ciudad, p.estado, COUNT(*) AS num " +
            "FROM propiedad p " +
            "JOIN barrio b ON b.id_barrio=p.id_barrio " +
            "JOIN ciudad c ON c.id_ciudad=b.id_ciudad " +
            "GROUP BY c.nombre_ciudad, p.estado ORDER BY c.nombre_ciudad");
        while (rs.next()) {
            String ciudad = rs.getString(1);
            String estado = rs.getString(2);
            int num = rs.getInt(3);
            java.util.LinkedHashMap<String, Integer> fila = porCiudad.get(ciudad);
            if (fila == null) { fila = new java.util.LinkedHashMap<String, Integer>(); porCiudad.put(ciudad, fila); }
            fila.put(estado, num);
            for (int i = 0; i < estados.length; i++) {
                if (estados[i].equalsIgnoreCase(estado)) totalesEstado[i] += num;
            }
            totalPropiedades += num;
        }
        rs.close();

        ResultSet rs2 = con.createStatement().executeQuery(
            "SELECT p.estado, COUNT(*) AS num, COALESCE(SUM(p.precio),0) AS monto " +
            "FROM propiedad p GROUP BY p.estado ORDER BY num DESC");
        while (rs2.next()) {
            String estado = rs2.getString(1);
            int num = rs2.getInt(2);
            double monto = rs2.getDouble(3);
            porEstado.add(new String[]{estado, String.valueOf(num), java.text.NumberFormat.getNumberInstance(Locale.US).format(monto)});
            totalCartera += monto;
        }
        rs2.close();

    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }

    String __tituloPanel = "Reporte de Propiedades por Ciudad y Estado";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<div class="row g-4">
    <div class="col-lg-8">
        <div class="card shadow-sm h-100">
            <div class="card-header bg-primary text-white fw-bold"><i class="bi bi-geo-alt"></i> Propiedades por ciudad y estado</div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-sm table-striped align-middle">
                        <thead class="table-light">
                        <tr>
                            <th>Ciudad</th>
                            <% for (String e : estados) { %><th class="text-center"><%= e.replace("_", " ") %></th><% } %>
                            <th class="text-center fw-bold">Total</th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Map.Entry<String, java.util.LinkedHashMap<String, Integer>> ent : porCiudad.entrySet()) {
                            int filaTotal = 0; %>
                            <tr>
                                <td><%= ent.getKey() %></td>
                                <% for (String e : estados) {
                                    Integer v = ent.getValue().get(e);
                                    int num = (v == null) ? 0 : v.intValue();
                                    filaTotal += num; %>
                                    <td class="text-center"><%= num %></td>
                                <% } %>
                                <td class="text-center fw-bold"><%= filaTotal %></td>
                            </tr>
                        <% } %>
                        <% if (porCiudad.isEmpty()) { %>
                            <tr><td colspan="6" class="text-muted">Sin datos.</td></tr>
                        <% } %>
                        </tbody>
                        <tfoot class="table-light">
                        <tr>
                            <th class="fw-bold">Total</th>
                            <% for (int t : totalesEstado) { %><th class="text-center"><%= t %></th><% } %>
                            <th class="text-center fw-bold"><%= totalPropiedades %></th>
                        </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-4">
        <div class="card shadow-sm h-100">
            <div class="card-header bg-success text-white fw-bold"><i class="bi bi-pie-chart"></i> Propiedades por estado</div>
            <div class="card-body">
                <% for (String[] f : porEstado) {
                    int num = Integer.parseInt(f[1]);
                    int pct = (totalPropiedades > 0) ? (int) Math.round(num * 100.0 / totalPropiedades) : 0;
                    String color = f[0].equals("Disponible") ? "bg-success" : f[0].equals("Alquilado") ? "bg-info" : f[0].equals("Vendido") ? "bg-primary" : "bg-secondary"; %>
                    <div class="d-flex justify-content-between mb-1">
                        <span><%= f[0].replace("_", " ") %></span>
                        <span class="fw-bold"><%= f[1] %></span>
                    </div>
                    <div class="progress mb-3" role="progressbar" aria-valuenow="<%= pct %>" aria-valuemin="0" aria-valuemax="100">
                        <div class="progress-bar <%= color %>" style="width:<%= pct %>%"></div>
                    </div>
                <% } %>
                <% if (porEstado.isEmpty()) { %><span class="text-muted">Sin datos.</span><% } %>
                <hr>
                <div class="d-flex justify-content-between">
                    <span>Total propiedades</span><span class="fw-bold"><%= totalPropiedades %></span>
                </div>
                <div class="d-flex justify-content-between">
                    <span>Cartera acumulada</span>
                    <span class="fw-bold">$ <%= java.text.NumberFormat.getNumberInstance(Locale.US).format(totalCartera) %></span>
                </div>
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