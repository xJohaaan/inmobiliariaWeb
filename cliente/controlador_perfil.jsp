<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    String nombres = request.getParameter("nombres");
    String apellidos = request.getParameter("apellidos");
    String documento = request.getParameter("documento");
    String telefono = request.getParameter("telefono");
    String direccion = request.getParameter("direccion");
    String foto = request.getParameter("foto");
    String ctx = request.getContextPath();
    Connection con = null;
    try {
        con = obtenerConexion();
        boolean existe = false;
        PreparedStatement psEx = con.prepareStatement("SELECT id_perfil FROM perfil WHERE id_usuario=?");
        psEx.setInt(1, idUsr);
        ResultSet rsEx = psEx.executeQuery();
        existe = rsEx.next();
        rsEx.close(); psEx.close();

        if (existe) {
            PreparedStatement psUp = con.prepareStatement(
                "UPDATE perfil SET nombres=?, apellidos=?, documento=?, telefono=?, direccion=?, foto=? WHERE id_usuario=?");
            psUp.setString(1, nombres); psUp.setString(2, apellidos); psUp.setString(3, documento);
            psUp.setString(4, telefono); psUp.setString(5, direccion); psUp.setString(6, foto);
            psUp.setInt(7, idUsr); psUp.executeUpdate(); psUp.close();
        } else {
            PreparedStatement psIns = con.prepareStatement(
                "INSERT INTO perfil (id_usuario, nombres, apellidos, documento, telefono, direccion, foto) VALUES (?,?,?,?,?,?,?)");
            psIns.setInt(1, idUsr); psIns.setString(2, nombres); psIns.setString(3, apellidos);
            psIns.setString(4, documento); psIns.setString(5, telefono); psIns.setString(6, direccion); psIns.setString(7, foto);
            psIns.executeUpdate(); psIns.close();
        }
        registrarAuditoria(con, idUsr, "Actualizó su perfil (documento " + documento + ")");
        session.setAttribute("flashPerfil", "Perfil guardado satisfactoriamente.");
    } catch (SQLException e) {
        if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
            session.setAttribute("flashPerfil", "Ese número de documento ya está registrado por otro usuario.");
        } else {
            session.setAttribute("flashPerfil", "Error al guardar el perfil.");
            e.printStackTrace();
        }
    } catch (Exception e) {
        session.setAttribute("flashPerfil", "Error al guardar el perfil.");
        e.printStackTrace();
    } finally {
        cerrarConexion(con);
    }
    response.sendRedirect(ctx + "/cliente/perfil.jsp");
%>