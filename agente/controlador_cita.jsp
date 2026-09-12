<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    String accion = request.getParameter("accion");
    int idCita = 0;
    try { idCita = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { idCita = 0; }
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    String ctx = request.getContextPath();
    Connection con = null;
    if (idCita > 0 && (accion.equals("aprobar") || accion.equals("rechazar"))) {
        try {
            con = obtenerConexion();
            PreparedStatement ps = con.prepareStatement("UPDATE cita SET estado=? WHERE id_cita=?");
            ps.setString(1, accion.equals("aprobar") ? "Aprobada" : "Rechazada");
            ps.setInt(2, idCita);
            ps.executeUpdate(); ps.close();
            registrarAuditoria(con, idUsr, (accion.equals("aprobar") ? "Aprobó " : "Rechazó ") + "la cita " + idCita);
            session.setAttribute("flashCitaAg", "Cita " + (accion.equals("aprobar") ? "aprobada" : "rechazada") + " correctamente.");
        } catch (Exception e) {
            session.setAttribute("flashCitaAg", "Error al actualizar la cita.");
            e.printStackTrace();
        } finally { cerrarConexion(con); }
    }
    response.sendRedirect(ctx + "/agente/citas.jsp");
%>