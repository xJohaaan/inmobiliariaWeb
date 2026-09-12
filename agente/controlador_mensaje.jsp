<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<% session.setAttribute("__rolesRequeridos", new String[]{"agente"}); %>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    int idMe = ((Integer) session.getAttribute("idUsuario")).intValue();
    String ctx = request.getContextPath();
    int idDest = 0, idProp = 0;
    try { idDest = Integer.parseInt(request.getParameter("id_destinatario")); } catch (Exception e) {}
    try { idProp = Integer.parseInt(request.getParameter("id_propiedad")); } catch (Exception e) {}
    String contenido = request.getParameter("contenido");

    if (idDest > 0 && idProp > 0 && idDest != idMe && contenido != null && !contenido.trim().isEmpty()) {
        Connection con = null;
        try {
            con = obtenerConexion();
            PreparedStatement psV = con.prepareStatement(
                "SELECT COUNT(*) FROM usuario u JOIN usuario_rol ur ON ur.id_usuario=u.id_usuario " +
                "JOIN rol r ON r.id_rol=ur.id_rol WHERE u.id_usuario=? AND u.estado='Activa' AND r.nombre='cliente'");
            psV.setInt(1, idDest);
            ResultSet rsV = psV.executeQuery();
            boolean valido = rsV.next() && rsV.getInt(1) > 0;
            rsV.close();
            psV.close();
            if (valido) {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO mensaje (id_remitente, id_destinatario, id_propiedad, contenido_texto) VALUES (?,?,?,?)");
                ps.setInt(1, idMe);
                ps.setInt(2, idDest);
                ps.setInt(3, idProp);
                ps.setString(4, contenido.trim());
                ps.executeUpdate();
                ps.close();
                registrarAuditoria(con, idMe, "Envió mensaje sobre la propiedad " + idProp + " al cliente " + idDest);
                session.setAttribute("flashMsj", "Mensaje enviado correctamente.");
            } else {
                session.setAttribute("flashMsj", "Error: el destinatario no es un cliente activo.");
            }
        } catch (Exception e) {
            session.setAttribute("flashMsj", "Error al enviar el mensaje.");
            e.printStackTrace();
        } finally {
            cerrarConexion(con);
        }
    }
    response.sendRedirect(ctx + "/agente/mensajes.jsp?con=" + idDest + "&prop=" + idProp);
%>