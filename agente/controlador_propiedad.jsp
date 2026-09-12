<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    String accion = request.getParameter("accion");
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    String ctx = request.getContextPath();

    if (accion != null && accion.equals("baja")) {
        Connection con = null;
        try {
            con = obtenerConexion();
            int id = Integer.parseInt(request.getParameter("id"));
            PreparedStatement ps = con.prepareStatement("UPDATE propiedad SET estado='De_baja' WHERE id_propiedad=?");
            ps.setInt(1, id);
            ps.executeUpdate(); ps.close();
            registrarAuditoria(con, idUsr, "Dio de baja la propiedad " + id);
            session.setAttribute("flashProp", "Propiedad dada de baja correctamente.");
        } catch (Exception e) {
            session.setAttribute("flashProp", "Error al dar de baja la propiedad.");
            e.printStackTrace();
        } finally { cerrarConexion(con); }
        response.sendRedirect(ctx + "/agente/mis_propiedades.jsp");
        return;
    }

    String matricula = request.getParameter("matricula");
    String idInmS = request.getParameter("id_inmobiliaria");
    String idBarS = request.getParameter("id_barrio");
    String idTnS = request.getParameter("id_tipo");
    String precio = request.getParameter("precio");
    String titulo = request.getParameter("titulo");
    String desc = request.getParameter("descripcion");
    String estado = request.getParameter("estado");
    String[] caracts = request.getParameterValues("caracteristicas");
    String[] imgs = request.getParameterValues("imagenes");

    Connection con = null;
    try {
        con = obtenerConexion();
        con.setAutoCommit(false);

        if (matricula == null || matricula.trim().isEmpty() || idInmS == null || idBarS == null ||
            idTnS == null || precio == null || titulo == null || titulo.trim().isEmpty()) {
            session.setAttribute("flashProp", "Error: Faltan campos obligatorios.");
        } else {
            int idInm = Integer.parseInt(idInmS);
            int idBar = Integer.parseInt(idBarS);
            int idTn = Integer.parseInt(idTnS);
            double pr = Double.parseDouble(precio);
            if (estado == null || estado.isEmpty()) estado = "Disponible";
            if (desc == null) desc = "";

            int idProp = 0;
            if (accion.equals("crear")) {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO propiedad (matricula_inmobiliaria, id_inmobiliaria, id_barrio, id_tipo, titulo_publicacion, descripcion, precio, estado) " +
                    "VALUES (?,?,?,?,?,?,?,?)", PreparedStatement.RETURN_GENERATED_KEYS);
                ps.setString(1, matricula.trim());
                ps.setInt(2, idInm); ps.setInt(3, idBar); ps.setInt(4, idTn);
                ps.setString(5, titulo.trim()); ps.setString(6, desc); ps.setDouble(7, pr); ps.setString(8, estado);
                ps.executeUpdate();
                ResultSet rk = ps.getGeneratedKeys();
                if (rk.next()) idProp = rk.getInt(1);
                rk.close(); ps.close();
                registrarAuditoria(con, idUsr, "Creó la propiedad " + idProp + " (" + matricula + ")");
            } else {
                idProp = Integer.parseInt(request.getParameter("id"));
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE propiedad SET id_inmobiliaria=?, id_barrio=?, id_tipo=?, titulo_publicacion=?, descripcion=?, precio=?, estado=? WHERE id_propiedad=?");
                ps.setInt(1, idInm); ps.setInt(2, idBar); ps.setInt(3, idTn);
                ps.setString(4, titulo.trim()); ps.setString(5, desc); ps.setDouble(6, pr); ps.setString(7, estado);
                ps.setInt(8, idProp);
                ps.executeUpdate(); ps.close();
                registrarAuditoria(con, idUsr, "Editó la propiedad " + idProp);
            }

            // Características (reemplaza las anteriores)
            PreparedStatement psDelC = con.prepareStatement("DELETE FROM propiedad_caracteristica WHERE id_propiedad=?");
            psDelC.setInt(1, idProp); psDelC.executeUpdate(); psDelC.close();
            if (caracts != null) {
                PreparedStatement psC = con.prepareStatement("INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica, cantidad) VALUES (?,?,?)");
                for (String cId : caracts) {
                    int idCar = Integer.parseInt(cId);
                    String cant = request.getParameter("cantidad_" + idCar);
                    int q = 1;
                    try { q = Integer.parseInt(cant); } catch (Exception e) { }
                    if (q <= 0) q = 1;
                    psC.setInt(1, idProp); psC.setInt(2, idCar); psC.setInt(3, q);
                    psC.addBatch();
                }
                psC.executeBatch(); psC.close();
            }

            // Imágenes (reemplaza las anteriores)
            PreparedStatement psDelI = con.prepareStatement("DELETE FROM imagen_propiedad WHERE id_propiedad=?");
            psDelI.setInt(1, idProp); psDelI.executeUpdate(); psDelI.close();
            if (imgs != null) {
                PreparedStatement psI = con.prepareStatement("INSERT INTO imagen_propiedad (id_propiedad, url_ruta_imagen) VALUES (?,?)");
                int insertadas = 0;
                for (String img : imgs) {
                    if (img != null && img.trim().length() > 5) {
                        psI.setInt(1, idProp); psI.setString(2, img.trim());
                        psI.addBatch(); insertadas++;
                    }
                }
                if (insertadas > 0) psI.executeBatch();
                psI.close();
            }

            con.commit();
            session.setAttribute("flashProp", "Propiedad guardada correctamente.");
        }
    } catch (SQLException e) {
        if (con != null) { try { con.rollback(); } catch (Exception e2) { } }
        if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
            session.setAttribute("flashProp", "Error: La matrícula inmobiliaria ya está registrada.");
        } else {
            session.setAttribute("flashProp", "Error al guardar la propiedad.");
            e.printStackTrace();
        }
    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception e2) { } }
        session.setAttribute("flashProp", "Error al guardar la propiedad: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (con != null) try { con.setAutoCommit(true); } catch (Exception e) { }
        cerrarConexion(con);
    }
    response.sendRedirect(ctx + "/agente/mis_propiedades.jsp");
%>