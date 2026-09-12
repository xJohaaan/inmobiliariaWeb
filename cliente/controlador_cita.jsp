<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    int idProp = 0;
    try { idProp = Integer.parseInt(request.getParameter("id_propiedad")); } catch (Exception e) { idProp = 0; }
    String fechaHora = request.getParameter("fecha_hora");
    String ctx = request.getContextPath();
    Connection con = null;
    if (idProp > 0 && fechaHora != null && !fechaHora.trim().isEmpty()) {
        int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
        try {
            con = obtenerConexion();
            String f = fechaHora.replace("T", " ");
            if (f.length() == 16) f = f + ":00";
            java.sql.Timestamp ts = java.sql.Timestamp.valueOf(f);
            PreparedStatement ps = con.prepareStatement("INSERT INTO cita (id_propiedad, id_usuario, fecha_hora, estado) VALUES (?,?,?,'Pendiente')");
            ps.setInt(1, idProp); ps.setInt(2, idUsr); ps.setTimestamp(3, ts);
            ps.executeUpdate(); ps.close();
            registrarAuditoria(con, idUsr, "Agendó cita para la propiedad " + idProp + " (" + fechaHora + ")");
            session.setAttribute("flashCita", "Cita agendada correctamente. Queda pendiente de aprobación.");
        } catch (SQLException e) {
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                session.setAttribute("flashCita", "Ya existe una cita en esa fecha para esta propiedad.");
            } else {
                session.setAttribute("flashCita", "Error al agendar la cita.");
                e.printStackTrace();
            }
        } catch (Exception e) {
            session.setAttribute("flashCita", "Fecha inválida. Usa el formato completo.");
            e.printStackTrace();
        } finally {
            cerrarConexion(con);
        }
    }
    response.sendRedirect(ctx + "/propiedad.jsp?id=" + idProp);
%>