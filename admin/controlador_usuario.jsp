<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"admin"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    int idUsrObjetivo = 0;
    try { idUsrObjetivo = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { idUsrObjetivo = 0; }
    String[] roles = request.getParameterValues("roles");
    String estado = request.getParameter("estado");
    int idAdmin = ((Integer) session.getAttribute("idUsuario")).intValue();
    String ctx = request.getContextPath();

    Connection con = null;
    if (idUsrObjetivo > 0) {
        try {
            con = obtenerConexion();
            con.setAutoCommit(false);

            // Reemplaza los roles existentes por los marcados en el formulario
            boolean tieneRol = false;
            PreparedStatement psCR = con.prepareStatement("SELECT COUNT(*) FROM usuario_rol WHERE id_usuario=?");
            psCR.setInt(1, idUsrObjetivo);
            ResultSet rsCR = psCR.executeQuery();
            if (rsCR.next()) tieneRol = rsCR.getInt(1) > 0;
            rsCR.close(); psCR.close();

            if (roles != null && roles.length > 0) {
                int idRol;
                PreparedStatement psB = con.prepareStatement("DELETE FROM usuario_rol WHERE id_usuario=?");
                psB.setInt(1, idUsrObjetivo); psB.executeUpdate(); psB.close();

                for (String r : roles) {
                    idRol = r.equals("admin") ? 1 : r.equals("agente") ? 2 : 3;
                    PreparedStatement psI = con.prepareStatement("INSERT INTO usuario_rol (id_usuario, id_rol) VALUES (?,?)");
                    psI.setInt(1, idUsrObjetivo); psI.setInt(2, idRol);
                    psI.executeUpdate(); psI.close();
                }
            } else if (tieneRol) {
                PreparedStatement psB = con.prepareStatement("DELETE FROM usuario_rol WHERE id_usuario=?");
                psB.setInt(1, idUsrObjetivo); psB.executeUpdate(); psB.close();
            }

            String estadoNuevo = (estado != null && estado.equals("Inactiva")) ? "Inactiva" : "Activa";
            if (idUsrObjetivo == idAdmin && estadoNuevo.equals("Inactiva")) {
                session.setAttribute("flashAdmin", "No puedes inactivar tu propia cuenta de administrador.");
            } else {
                PreparedStatement psE = con.prepareStatement("UPDATE usuario SET estado=? WHERE id_usuario=?");
                psE.setString(1, estadoNuevo); psE.setInt(2, idUsrObjetivo);
                psE.executeUpdate(); psE.close();

                PreparedStatement psCorreo = con.prepareStatement("SELECT correo FROM usuario WHERE id_usuario=?");
                psCorreo.setInt(1, idUsrObjetivo);
                ResultSet rsC = psCorreo.executeQuery();
                String correo = "";
                if (rsC.next()) correo = rsC.getString(1);
                rsC.close(); psCorreo.close();
                registrarAuditoria(con, idAdmin, "Actualizó roles/estado del usuario " + correo + " (id " + idUsrObjetivo + ")");
                con.commit();
                session.setAttribute("flashAdmin", "Usuario " + correo + " actualizado correctamente.");
            }
        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception e2) { }
            session.setAttribute("flashAdmin", "Error al actualizar el usuario.");
            e.printStackTrace();
        } finally {
            try { if (con != null) con.setAutoCommit(true); } catch (Exception e) { }
            cerrarConexion(con);
        }
    }
    response.sendRedirect(ctx + "/admin/usuarios.jsp");
%>