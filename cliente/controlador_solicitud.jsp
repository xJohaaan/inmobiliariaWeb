<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.util.*, javax.servlet.http.Part" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"cliente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/auditoria.jspf" %>
<%
    int idUsr = ((Integer) session.getAttribute("idUsuario")).intValue();
    String ctx = request.getContextPath();
    Integer idPropiedad = null;
    String tipoTramite = null;

    Connection con = null;
    try {
        con = obtenerConexion();
        con.setAutoCommit(false);

        String rutaBase = application.getRealPath("/uploads/solicitudes");
        File dirBase = new File(rutaBase);
        if (!dirBase.exists()) dirBase.mkdirs();

        java.util.ArrayList<String[]> docsSubidos = new java.util.ArrayList<String[]>();

        java.util.Collection<Part> partes = request.getParts();
        for (Part part : partes) {
            String nombreCampo = part.getName();
            if (nombreCampo.equals("id_propiedad")) {
                BufferedReader br = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"));
                idPropiedad = Integer.parseInt(br.readLine().trim());
                br.close();
            } else if (nombreCampo.equals("tipo_tramite")) {
                BufferedReader br = new BufferedReader(new InputStreamReader(part.getInputStream(), "UTF-8"));
                tipoTramite = br.readLine().trim();
                br.close();
            } else if (nombreCampo.equals("documentos") && part.getSize() > 0) {
                String nombreOriginal = new File(part.getSubmittedFileName()).getName();
                nombreOriginal = nombreOriginal.replaceAll("[^A-Za-z0-9._-]", "_");
                String archivoDestino = System.currentTimeMillis() + "-" + idUsr + "-" + nombreOriginal;
                File destino = new File(dirBase, archivoDestino);
                part.write(destino.getAbsolutePath());
                docsSubidos.add(new String[]{nombreOriginal, "uploads/solicitudes/" + archivoDestino});
            }
        }

        if (idPropiedad == null || tipoTramite == null || tipoTramite.isEmpty()) {
            session.setAttribute("flashSolicitud", "Error: Debes seleccionar propiedad y tipo de trámite.");
        } else if (docsSubidos.isEmpty()) {
            session.setAttribute("flashSolicitud", "Adjunta al menos un documento para radicar la solicitud.");
        } else {
            PreparedStatement psSol = con.prepareStatement(
                "INSERT INTO solicitud (id_propiedad, id_usuario, tipo_tramite, estado) VALUES (?,?,?,'En revisión')",
                Statement.RETURN_GENERATED_KEYS);
            psSol.setInt(1, idPropiedad);
            psSol.setInt(2, idUsr);
            psSol.setString(3, tipoTramite);
            psSol.executeUpdate();
            ResultSet rsKey = psSol.getGeneratedKeys();
            int idSolicitud = 0;
            if (rsKey.next()) idSolicitud = rsKey.getInt(1);
            rsKey.close(); psSol.close();

            PreparedStatement psDoc = con.prepareStatement(
                "INSERT INTO documento_solicitud (id_solicitud, nombre_documento, ruta_archivo) VALUES (?,?,?)");
            for (String[] d : docsSubidos) {
                psDoc.setInt(1, idSolicitud);
                psDoc.setString(2, d[0]);
                psDoc.setString(3, d[1]);
                psDoc.addBatch();
            }
            psDoc.executeBatch();
            psDoc.close();

            registrarAuditoria(con, idUsr, "Radicó solicitud " + idSolicitud + " (" + tipoTramite + ") para propiedad " + idPropiedad);
            con.commit();
            session.setAttribute("flashSolicitud", "Solicitud radicada correctamente con " + docsSubidos.size() + " documento(s).");
        }
    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception e2) { } }
        session.setAttribute("flashSolicitud", "Error al radicar la solicitud: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (con != null) try { con.setAutoCommit(true); } catch (Exception e) { }
        cerrarConexion(con);
    }
    response.sendRedirect(ctx + "/cliente/mis_solicitudes.jsp");
%>