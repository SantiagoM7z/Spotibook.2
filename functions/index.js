const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

admin.initializeApp();

sgMail.setApiKey("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");

exports.sendVerificationEmail = functions.auth.user().onCreate(async (user) => {
  const codigoVerificacion = Math.floor(100000 + Math.random() * 900000);

    await admin.firestore().collection('verificaciones').doc(user.uid).set({
        codigo: codigoVerificacion,
        email: user.email,
        creadoEn: admin.firestore.FieldValue.serverTimestamp()
    });

    const msg = {
        to: user.email,
        from: "santio.martinezz@gmail.com", // Cambia por tu correo verificado en SendGrid
        templateId: "d-56dd645334cc4b8b8b4714a29f846275",
        dynamic_template_data: {
            nombre_usuario: user.displayName || "Nuevo Usuario",
            codigo_verificacion: codigoVerificacion
        },
    };
    
    return sgMail.send(msg);
});
