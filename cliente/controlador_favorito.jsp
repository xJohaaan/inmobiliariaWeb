<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Locale" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    String usuario = (String) session.getAttribute("usuarioLogueado");
    int idProp = 0;
    try { idProp = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { idProp = 0; }
    Connection con = null;
    String flash = (String) session.getAttribute("flashFav");
    session.removeAttribute("flashFav");
    if (idProp > 0) {
        try {
            con = obtenerConexion();
            PreparedStatement pchk = con.prepareStatement("SELECT id_favorito FROM favorito WHERE id_usuario=? AND id_propiedad=?");
            pchk.setInt(1, ((Integer) session.getAttribute("idUsuario")).intValue());
            pchk.setInt(2, idProp);
            ResultSet rchk = pchk.executeQuery();
            if (rchk.next()) {
                rchk.close(); pchk.close();
                PreparedStatement pdel = con.prepareStatement("DELETE FROM favorito WHERE id_usuario=? AND id_propiedad=?");
                pdel.setInt(1, ((Integer) session.getAttribute("idUsuario")).intValue());
                pdel.setInt(2, idProp);
                pdel.executeUpdate(); pdel.close();
                session.setAttribute("flashFav", "Se quitó la propiedad de tus favoritos.");
            } else {
                rchk.close(); pchk.close();
                PreparedStatement pins = con.prepareStatement("INSERT INTO favorito (id_usuario, id_propiedad) VALUES (?, ?)");
                pins.setInt(1, ((Integer) session.getAttribute("idUsuario")).intValue());
                pins.setInt(2, idProp);
                pins.executeUpdate(); pins.close();
                session.setAttribute("flashFav", "Propiedad agregada a tus favoritos.");
            }
        } catch (Exception e) {
            session.setAttribute("flashFav", "Error al actualizar favoritos.");
            e.printStackTrace();
        } finally {
            cerrarConexion(con);
        }
    }
    String accion = request.getParameter("accion");
    String ctx = request.getContextPath();
    if (accion != null && accion.equals("panel")) {
        response.sendRedirect(ctx + "/cliente/mis_favoritos.jsp");
    } else {
        response.sendRedirect(ctx + "/propiedad.jsp?id=" + idProp);
    }
%>