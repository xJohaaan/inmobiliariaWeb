<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Locale" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    Connection con = null;

    java.util.ArrayList<String[]> r1 = new java.util.ArrayList<String[]>(); // propiedades disponibles por ciudad
    java.util.ArrayList<String[]> r2 = new java.util.ArrayList<String[]>(); // citas por estado
    java.util.ArrayList<String[]> r3 = new java.util.ArrayList<String[]>(); // solicitudes por inmobiliaria
    java.util.ArrayList<String[]> r4 = new java.util.ArrayList<String[]>(); // ventas/arriendos por inmobiliaria

    try {
        con = obtenerConexion();

        ResultSet rs1 = con.createStatement().executeQuery(
            "SELECT c.nombre_ciudad, COUNT(p.id_propiedad) AS total, SUM(p.precio) AS valor_cartera " +
            "FROM propiedad p JOIN barrio b ON b.id_barrio=p.id_barrio JOIN ciudad c ON c.id_ciudad=b.id_ciudad " +
            "WHERE p.estado='Disponible' GROUP BY c.nombre_ciudad ORDER BY total DESC");
        while (rs1.next()) r1.add(new String[]{rs1.getString(1), String.valueOf(rs1.getInt(2)), rs1.getString(3)});
        rs1.close();

        ResultSet rs2 = con.createStatement().executeQuery(
            "SELECT c.estado, COUNT(*) AS total FROM cita c GROUP BY c.estado ORDER BY total DESC");
        while (rs2.next()) r2.add(new String[]{rs2.getString(1), String.valueOf(rs2.getInt(2))});
        rs2.close();

        ResultSet rs3 = con.createStatement().executeQuery(
            "SELECT i.nombre_empresa, s.tipo_tramite, COUNT(*) AS total, " +
            "SUM(CASE WHEN s.estado='Aprobada' THEN 1 ELSE 0 END) AS aprobadas " +
            "FROM solicitud s JOIN propiedad p ON p.id_propiedad=s.id_propiedad " +
            "JOIN inmobiliaria i ON i.id_inmobiliaria=p.id_inmobiliaria " +
            "GROUP BY i.nombre_empresa, s.tipo_tramite ORDER BY i.nombre_empresa");
        while (rs3.next()) r3.add(new String[]{rs3.getString(1), rs3.getString(2), String.valueOf(rs3.getInt(3)), String.valueOf(rs3.getInt(4))});
        rs3.close();

        ResultSet rs4 = con.createStatement().executeQuery(
            "SELECT i.nombre_empresa, p.estado, COUNT(*) AS num, COALESCE(SUM(p.precio),0) AS monto " +
            "FROM propiedad p JOIN inmobiliaria i ON i.id_inmobiliaria=p.id_inmobiliaria " +
            "WHERE p.estado IN ('Vendido','Alquilado') GROUP BY i.nombre_empresa, p.estado ORDER BY i.nombre_empresa");
        while (rs4.next()) r4.add(new String[]{rs4.getString(1), rs4.getString(2), String.valueOf(rs4.getInt(3)), rs4.getString(4)});
        rs4.close();

    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }

    String __tituloPanel = "Reportes Consolidados";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<div class="row g-4">
    <div class="col-lg-6">
        <div class="card shadow-sm h-100">
            <div class="card-header bg-primary text-white fw-bold"><i class="bi bi-geo-alt"></i> Propiedades disponibles por ciudad</div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead><tr><th>Ciudad</th><th>Disponibles</th><th>Valor cartera</th></tr></thead>
                        <tbody>
                        <% for (String[] f : r1) { %>
                            <tr><td><%= f[0] %></td><td class="fw-bold"><%= f[1] %></td><td>$ <%= String.format(Locale.US, "%,.0f", Double.parseDouble(f[2])) %></td></tr>
                        <% } %>
                        <% if (r1.isEmpty()) { %><tr><td colspan="3" class="text-muted">Sin datos.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card shadow-sm h-100">
            <div class="card-header bg-success text-white fw-bold"><i class="bi bi-calendar-check"></i> Citas por estado</div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead><tr><th>Estado</th><th>Cantidad</th></tr></thead>
                        <tbody>
                        <% for (String[] f : r2) { %>
                            <tr><td><%= f[0] %></td><td class="fw-bold"><%= f[1] %></td></tr>
                        <% } %>
                        <% if (r2.isEmpty()) { %><tr><td colspan="2" class="text-muted">Sin datos.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card shadow-sm h-100">
            <div class="card-header bg-info text-white fw-bold"><i class="bi bi-inboxes"></i> Solicitudes por inmobiliaria</div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead><tr><th>Inmobiliaria</th><th>Trámite</th><th>Total</th><th>Aprobadas</th></tr></thead>
                        <tbody>
                        <% for (String[] f : r3) { %>
                            <tr><td><%= f[0] %></td><td><%= f[1] %></td><td><%= f[2] %></td><td><%= f[3] %></td></tr>
                        <% } %>
                        <% if (r3.isEmpty()) { %><tr><td colspan="4" class="text-muted">Sin datos.</td></tr><% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="col-lg-6">
        <div class="card shadow-sm h-100">
            <div class="card-header bg-warning text-dark fw-bold"><i class="bi bi-graph-up-arrow"></i> Reporte de ventas y arriendos</div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead><tr><th>Inmobiliaria</th><th>Movimiento</th><th>N.&deg;</th><th>Total</th></tr></thead>
                        <tbody>
                        <% for (String[] f : r4) { %>
                            <tr><td><%= f[0] %></td><td><%= f[1] %></td><td><%= f[2] %></td><td>$ <%= String.format(Locale.US, "%,.0f", Double.parseDouble(f[3])) %></td></tr>
                        <% } %>
                        <% if (r4.isEmpty()) { %><tr><td colspan="4" class="text-muted">Sin datos.</td></tr><% } %>
                        </tbody>
                    </table>
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