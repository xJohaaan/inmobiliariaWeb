<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>
<% session.setAttribute("__rolesRequeridos", new String[]{"cliente"}); %>
<%
    String __tituloPanel = "Mensajes";
%>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%--
  Panel de mensajes del cliente: lista conversaciones (contacto + propiedad),
  permite ver/responder un hilo y contactar a un agente por una propiedad.
--%>
<%
    int idMe = ((Integer) session.getAttribute("idUsuario")).intValue();
    String ctx = request.getContextPath();
    String flashMsj = (String) session.getAttribute("flashMsj");
    session.removeAttribute("flashMsj");

    int con = 0, prop = 0;
    try { con = Integer.parseInt(request.getParameter("con")); } catch (Exception e) {}
    try { prop = Integer.parseInt(request.getParameter("prop")); } catch (Exception e) {}

    Connection conBd = null;
    String nomOtro = "", corrOtro = "", tituloProp = "";
    if (con > 0 && prop > 0) {
        try {
            conBd = obtenerConexion();
            PreparedStatement ps = conBd.prepareStatement(
                "SELECT u.correo, COALESCE(NULLIF(pf.nombres,''),'') AS nombres, COALESCE(NULLIF(pf.apellidos,''),'') AS apellidos, " +
                "pr.titulo_publicacion FROM usuario u LEFT JOIN perfil pf ON pf.id_usuario=u.id_usuario, propiedad pr " +
                "WHERE u.id_usuario=? AND pr.id_propiedad=?");
            ps.setInt(1, con);
            ps.setInt(2, prop);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                corrOtro = rs.getString("correo");
                String nom = rs.getString("nombres");
                String ape = rs.getString("apellidos");
                nomOtro = (nom + " " + ape).trim();
                if (nomOtro.isEmpty()) nomOtro = corrOtro;
                tituloProp = rs.getString("titulo_publicacion");
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conBd != null) { try { conBd.close(); } catch (Exception e) {} }
        }
    }
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm a");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mensajes - <%= __tituloPanel %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>
    <div class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="mb-0"><i class="bi bi-chat-dots"></i> Mensajes</h4>
            <a href="index.jsp" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i> Mi panel</a>
        </div>

        <% if (flashMsj != null) { %>
            <div class="alert alert-info alert-dismissible fade show" role="alert">
                <%= flashMsj %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
            </div>
        <% } %>

        <% if (prop > 0) { %>
        <div class="card mb-3">
            <div class="card-header bg-white"><i class="bi bi-plus-circle"></i> Iniciar conversación</div>
            <div class="card-body">
                <%
                    Connection conC = null;
                    String titPropNuevo = "";
                    try {
                        conC = obtenerConexion();
                        PreparedStatement ps = conC.prepareStatement("SELECT titulo_publicacion FROM propiedad WHERE id_propiedad=?");
                        ps.setInt(1, prop);
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) titPropNuevo = rs.getString("titulo_publicacion");
                        rs.close();
                        ps.close();
                    } catch (Exception e) { e.printStackTrace(); }
                %>
                <p class="mb-3"><strong>Propiedad:</strong> <%= titPropNuevo != null && !titPropNuevo.isEmpty() ? titPropNuevo : ("#" + prop) %></p>
                <form action="controlador_mensaje.jsp" method="post">
                    <input type="hidden" name="id_propiedad" value="<%= prop %>">
                    <div class="mb-3">
                        <label class="form-label">Contactar con el agente:</label>
                        <select name="id_destinatario" class="form-select" required>
                            <option value="">-- Seleccione un agente --</option>
                            <%
                                if (conC == null) {
                                    try { conC = obtenerConexion(); } catch (Exception e) { e.printStackTrace(); }
                                }
                                if (conC != null) {
                                    PreparedStatement ps = conC.prepareStatement(
                                        "SELECT u.id_usuario, u.correo, COALESCE(NULLIF(pf.nombres,''),'') AS nombres, " +
                                        "COALESCE(NULLIF(pf.apellidos,''),'') AS apellidos " +
                                        "FROM usuario u JOIN usuario_rol ur ON ur.id_usuario=u.id_usuario " +
                                        "JOIN rol r ON r.id_rol=ur.id_rol LEFT JOIN perfil pf ON pf.id_usuario=u.id_usuario " +
                                        "WHERE u.estado='Activa' AND r.nombre='agente' AND u.id_usuario<>? ORDER BY u.correo");
                                    ps.setInt(1, idMe);
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                                        String nm = rs.getString("nombres").trim();
                                        String ap = rs.getString("apellidos").trim();
                                        String etq = ((nm + " " + ap).trim() + " (" + rs.getString("correo") + ")").trim();
                                        if (etq.equals("(" + rs.getString("correo") + ")")) etq = rs.getString("correo");
                            %>
                            <option value="<%= rs.getInt("id_usuario") %>"><%= etq %></option>
                            <%      }
                                }
                            %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mensaje:</label>
                        <textarea name="contenido" class="form-control" rows="3" maxlength="2000" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary"><i class="bi bi-send"></i> Enviar</button>
                </form>
                <% try { if (conC != null) conC.close(); } catch (Exception e) {} %>
            </div>
        </div>
        <% } %>

        <% if (con > 0 && prop > 0) { %>
        <div class="card mb-3">
            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                <div>
                    <strong><i class="bi bi-person-circle"></i> <%= nomOtro %></strong>
                    <a href="<%= request.getContextPath() %>/propiedad.jsp?id=<%= prop %>" class="ms-2 small text-decoration-none"><i class="bi bi-house-door"></i> <%= tituloProp %></a>
                </div>
                <a href="mensajes.jsp" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i> Volver</a>
            </div>
            <div class="card-body" style="max-height: 420px; overflow-y: auto; background: #f8f9fa;">
                <%
                    Connection conT = null;
                    try {
                        conT = obtenerConexion();
                        PreparedStatement ps = conT.prepareStatement(
                            "SELECT m.*, u.correo FROM mensaje m JOIN usuario u ON u.id_usuario=m.id_remitente " +
                            "WHERE ((m.id_remitente=? AND m.id_destinatario=? AND m.id_propiedad=?) " +
                            "OR (m.id_remitente=? AND m.id_destinatario=? AND m.id_propiedad=?)) " +
                            "ORDER BY m.fecha_envio ASC");
                        ps.setInt(1, idMe); ps.setInt(2, con); ps.setInt(3, prop);
                        ps.setInt(4, con); ps.setInt(5, idMe); ps.setInt(6, prop);
                        ResultSet rs = ps.executeQuery();
                        boolean vacio = true;
                        while (rs.next()) {
                            vacio = false;
                            boolean mio = (rs.getInt("id_remitente") == idMe);
                %>
                <div class="d-flex <%= mio ? "justify-content-end" : "justify-content-start" %> mb-2">
                    <div class="<%= mio ? "bg-primary text-white" : "bg-white" %> rounded-3 px-3 py-2 shadow-sm" style="max-width: 75%;">
                        <small class="d-block <%= mio ? "text-white-50" : "text-secondary" %>">
                            <%= mio ? "Tú" : nomOtro %> &middot; <%= sdf.format(rs.getTimestamp("fecha_envio")) %>
                        </small>
                        <div class="text-break"><%= rs.getString("contenido_texto") %></div>
                    </div>
                </div>
                <%      }
                        rs.close();
                        ps.close();
                        if (vacio) { %>
                <div class="text-center text-secondary py-4"><i class="bi bi-chat-square-dots"></i> Aún no hay mensajes en esta conversación.</div>
                <%      }
                        PreparedStatement psU = conT.prepareStatement(
                            "UPDATE mensaje SET leido=1 WHERE id_destinatario=? AND id_remitente=? AND id_propiedad=? AND leido=0");
                        psU.setInt(1, idMe); psU.setInt(2, con); psU.setInt(3, prop);
                        psU.executeUpdate();
                        psU.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if (conT != null) conT.close(); } catch (Exception e) {}
                    }
                %>
            </div>
            <div class="card-footer bg-white">
                <form action="controlador_mensaje.jsp" method="post" class="d-flex gap-2">
                    <input type="hidden" name="id_destinatario" value="<%= con %>">
                    <input type="hidden" name="id_propiedad" value="<%= prop %>">
                    <input type="text" name="contenido" class="form-control" maxlength="2000" placeholder="Escribe tu respuesta..." required>
                    <button type="submit" class="btn btn-primary flex-shrink-0"><i class="bi bi-send"></i></button>
                </form>
            </div>
        </div>
        <% } else { %>
        <div class="card">
            <div class="card-header bg-white"><i class="bi bi-chat-left-text"></i> Conversaciones</div>
            <div class="card-body p-0">
                <%
                    Connection conL = null;
                    try {
                        conL = obtenerConexion();
                        PreparedStatement ps = conL.prepareStatement(
                            "SELECT conv.otro, conv.id_propiedad, conv.nueva, p.titulo_publicacion, u.correo, " +
                            "COALESCE(NULLIF(pf.nombres,''),'') AS nombres, COALESCE(NULLIF(pf.apellidos,''),'') AS apellidos " +
                            "FROM (SELECT CASE WHEN id_remitente=? THEN id_destinatario ELSE id_remitente END AS otro, " +
                            "id_propiedad, MAX(fecha_envio) AS ult, " +
                            "SUM(CASE WHEN id_destinatario=? AND leido=0 THEN 1 ELSE 0 END) AS nueva " +
                            "FROM mensaje WHERE id_remitente=? OR id_destinatario=? GROUP BY otro, id_propiedad) conv " +
                            "JOIN propiedad p ON p.id_propiedad=conv.id_propiedad " +
                            "JOIN usuario u ON u.id_usuario=conv.otro " +
                            "LEFT JOIN perfil pf ON pf.id_usuario=conv.otro " +
                            "ORDER BY conv.ult DESC");
                        ps.setInt(1, idMe); ps.setInt(2, idMe); ps.setInt(3, idMe); ps.setInt(4, idMe);
                        ResultSet rs = ps.executeQuery();
                        boolean hay = false;
                %>
                <table class="table table-hover mb-0 align-middle">
                    <thead class="table-light">
                        <tr><th>Contacto</th><th>Propiedad</th><th>Nuevos</th><th></th></tr>
                    </thead>
                    <tbody>
                <%
                        while (rs.next()) {
                            hay = true;
                            String nm = rs.getString("nombres").trim();
                            String ap = rs.getString("apellidos").trim();
                            String etq = (nm + " " + ap).trim();
                            if (etq.isEmpty()) etq = rs.getString("correo");
                            int nueva = rs.getInt("nueva");
                %>
                        <tr>
                            <td><i class="bi bi-person-circle"></i> <%= etq %><br><small class="text-secondary"><%= rs.getString("correo") %></small></td>
                            <td><a href="<%= request.getContextPath() %>/propiedad.jsp?id=<%= rs.getInt("id_propiedad") %>" class="text-decoration-none"><%= rs.getString("titulo_publicacion") %></a></td>
                            <td><% if (nueva > 0) { %><span class="badge rounded-pill text-bg-danger"><%= nueva %></span><% } else { %><span class="badge rounded-pill text-bg-secondary">0</span><% } %></td>
                            <td class="text-end">
                                <a href="mensajes.jsp?con=<%= rs.getInt("otro") %>&amp;prop=<%= rs.getInt("id_propiedad") %>" class="btn btn-sm btn-outline-primary"><i class="bi bi-chat-left-text"></i> Abrir</a>
                            </td>
                        </tr>
                <%      }
                        rs.close();
                        ps.close();
                        if (!hay) {
                %>
                    </tbody>
                </table>
                <div class="text-center text-secondary py-5">
                    <i class="bi bi-chat-square-dots fs-1"></i>
                    <p class="mt-2 mb-1">No tienes conversaciones todavía.</p>
                    <small>Entra a la ficha de una propiedad y pulsa <strong>Contactar por mensaje</strong> para hablar con la inmobiliaria.</small>
                </div>
                <%      } else { %>
                    </tbody>
                </table>
                <%      }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        try { if (conL != null) conL.close(); } catch (Exception e) {}
                    }
                %>
            </div>
        </div>
        <% } %>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>