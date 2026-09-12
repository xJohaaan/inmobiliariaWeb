<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"admin"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    String accion = request.getParameter("accion");
    String entidad = request.getParameter("entidad");
    int idAdmin = ((Integer) session.getAttribute("idUsuario")).intValue();
    String ctx = request.getContextPath();
    Connection con = null;
    try {
        con = obtenerConexion();
        if (accion != null && accion.equals("agregar")) {
            if (entidad.equals("ciudad")) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO ciudad (nombre_ciudad) VALUES (?)");
                ps.setString(1, request.getParameter("nombre")); ps.executeUpdate(); ps.close();
            } else if (entidad.equals("barrio")) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO barrio (id_ciudad, nombre_barrio, estrato) VALUES (?,?,?)");
                ps.setInt(1, Integer.parseInt(request.getParameter("id_ciudad")));
                ps.setString(2, request.getParameter("nombre"));
                ps.setInt(3, Integer.parseInt(request.getParameter("estrato")));
                ps.executeUpdate(); ps.close();
            } else if (entidad.equals("tipo")) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO tipo_propiedad (nombre) VALUES (?)");
                ps.setString(1, request.getParameter("nombre")); ps.executeUpdate(); ps.close();
            } else if (entidad.equals("caracteristica")) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO caracteristica (nombre) VALUES (?)");
                ps.setString(1, request.getParameter("nombre")); ps.executeUpdate(); ps.close();
            } else if (entidad.equals("inmobiliaria")) {
                PreparedStatement ps = con.prepareStatement("INSERT INTO inmobiliaria (nit, nombre_empresa, telefono, correo_contacto) VALUES (?,?,?,?)");
                ps.setString(1, request.getParameter("nit"));
                ps.setString(2, request.getParameter("nombre"));
                ps.setString(3, request.getParameter("telefono"));
                ps.setString(4, request.getParameter("correo"));
                ps.executeUpdate(); ps.close();
            }
            registrarAuditoria(con, idAdmin, "Agregó " + entidad + " al catálogo");
            session.setAttribute("flashCat", entidad + " agregado correctamente.");
        } else if (accion != null && accion.equals("eliminar")) {
            int id = Integer.parseInt(request.getParameter("id"));
            String tabla = entidad.equals("ciudad") ? "ciudad" : entidad.equals("barrio") ? "barrio"
                          : entidad.equals("tipo") ? "tipo_propiedad" : entidad.equals("caracteristica") ? "caracteristica" : "inmobiliaria";
            String col = entidad.equals("tipo") ? "id_tipo" : entidad.equals("caracteristica") ? "id_caracteristica" : entidad.equals("barrio") ? "id_barrio" : entidad.equals("ciudad") ? "id_ciudad" : "id_inmobiliaria";
            PreparedStatement ps = con.prepareStatement("DELETE FROM " + tabla + " WHERE " + col + "=?");
            ps.setInt(1, id);
            ps.executeUpdate(); ps.close();
            registrarAuditoria(con, idAdmin, "Eliminó " + entidad + " id " + id + " del catálogo");
            session.setAttribute("flashCat", entidad + " eliminado correctamente.");
        }
    } catch (SQLException e) {
        if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
            session.setAttribute("flashCat", "Error: Ese registro ya existe o está en uso.");
        } else {
            session.setAttribute("flashCat", "Error: No se puede eliminar porque está en uso (" + e.getMessage() + ")");
            e.printStackTrace();
        }
    } catch (Exception e) {
        session.setAttribute("flashCat", "Error al procesar el catálogo.");
        e.printStackTrace();
    } finally { cerrarConexion(con); }
    response.sendRedirect(ctx + "/admin/catalogos.jsp");
%>