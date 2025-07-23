const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true }); // Importa y configura CORS

admin.initializeApp();

exports.resetPasswordWithEmail = functions.https.onRequest(async (req, res) => {
  cors(req, res, async () => { // Envuelve tu lógica dentro de cors
    // LOG DEL ENCABEZADO RECIBIDO - ¡AQUÍ ESTÁ EL CAMBIO IMPORTANTE!
    console.log('Headers recibidos:', req.headers);
    console.log('Content-Type recibido:', req.headers['content-type']);

    if (req.method === 'OPTIONS') {
      // Manejar solicitudes OPTIONS (pre-vuelo CORS)
        res.set('Access-Control-Allow-Methods', 'POST');
        res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
        res.set('Access-Control-Max-Age', '3600');
        return res.status(204).send('');
    }

    if (req.method !== 'POST') {
        return res.status(405).json({ status: 'error', message: 'Método no permitido. Solo POST.' });
    }

    // A pesar de que Flutter lo envía bien, el error persiste.
    // Podría ser un tema de minúsculas/mayúsculas o espacios extra.
    // Vamos a hacer la comprobación un poco más robusta.
    const contentType = req.headers['content-type'] ? req.headers['content-type'].toLowerCase().trim() : '';

    if (!contentType.includes('application/json')) { // Usamos includes para ser más flexibles
        console.error('Content-Type inesperado:', req.headers['content-type']);
        return res.status(400).json({ status: 'error', message: 'Content-Type debe ser application/json.' });
    }

    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
        console.error('Email o nueva contraseña faltantes en el cuerpo de la solicitud.');
        return res.status(400).json({ status: 'error', message: 'Email y nueva contraseña son obligatorios.' });
    }

    if (newPassword.length < 8) {
        console.error('Contraseña demasiado corta:', newPassword.length);
        return res.status(400).json({ status: 'error', message: 'La contraseña debe tener al menos 8 caracteres.' });
    }

    try {
      // 1. Verificar si el usuario existe
        const userRecord = await admin.auth().getUserByEmail(email);

      // 2. Actualizar la contraseña del usuario
        await admin.auth().updateUser(userRecord.uid, { password: newPassword });

        console.log(`Contraseña actualizada para el usuario: ${email}`);
        return res.status(200).json({ status: 'success', message: 'Contraseña restablecida exitosamente.' });

    } catch (error) {
        console.error('Error al restablecer contraseña en Cloud Function:', error);
        let errorMessage = 'Error interno del servidor al restablecer la contraseña.';
        let errorCode = 'internal_error';

    if (error.code) {
        errorCode = error.code;
        switch (error.code) {
        case 'auth/user-not-found':
            errorMessage = 'No se encontró una cuenta con ese correo electrónico.';
            break;
        case 'auth/invalid-email':
            errorMessage = 'El formato del correo electrónico es inválido.';
            break;
        case 'auth/weak-password':
            errorMessage = 'La nueva contraseña es demasiado débil. Usa al menos 6 caracteres.';
            break;
        default:
            errorMessage = `Error de Firebase Auth: ${error.message}`;
        }
    }
    return res.status(500).json({ status: 'error', message: errorMessage, errorCode: errorCode });
    }
});
});