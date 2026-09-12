<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    String accion = request.getParameter("accion");
    int idSol = 0;
    try { idSol = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { idSol = 0; }
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    String ctx = request.getContextPath();
    Connection con = null;
    if (idSol > 0 && (accion.equals("aprobar") || accion.equals("rechazar"))) {
        try {
            con = obtenerConexion();
            PreparedStatement ps = con.prepareStatement("UPDATE solicitud SET estado=? WHERE id_solicitud=?");
            ps.setString(1, accion.equals("aprobar") ? "Aprobada" : "Rechazada");
            ps.setInt(2, idSol);
            ps.executeUpdate(); ps.close();
            registrarAuditoria(con, idUsr, (accion.equals("aprobar") ? "Aprobó " : "Rechazó ") + "la solicitud " + idSol);
            session.setAttribute("flashSolicAg", "Solicitud " + (accion.equals("aprobar") ? "aprobada" : "rechazada") + " correctamente.");
        } catch (Exception e) {
            session.setAttribute("flashSolicAg", "Error al actualizar la solicitud.");
            e.printStackTrace();
        } finally { cerrarConexion(con); }
    }
    response.sendRedirect(ctx + "/agente/solicitudes.jsp");
%>