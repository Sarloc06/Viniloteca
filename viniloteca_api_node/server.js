const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcrypt');
const cors = require('cors');
// --- IMPORTS PARA SUBIR ARCHIVOS ---
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json());

// --- CONFIGURACIÓN DE CARPETA UPLOADS ---
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}
app.use('/uploads', express.static('uploads'));

// --- CONFIGURACIÓN MULTER ---
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(unirandom = Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});
const upload = multer({ storage: storage });

// --- CONEXIÓN BASE DE DATOS ---
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'viniloteca'
});

db.connect(err => {
    if (err) {
        console.error('Error MySQL:', err.message);
    } else {
        console.log('✅ Conectado a MySQL.');
        
        // --- AUTO-CREACIÓN DE TABLA DE RESEÑAS ---
        const createTableQuery = `
            CREATE TABLE IF NOT EXISTS RESENAS (
                id INT AUTO_INCREMENT PRIMARY KEY,
                id_tienda INT,
                id_usuario INT,
                texto TEXT,
                valoracion INT,
                likes INT DEFAULT 0,
                dislikes INT DEFAULT 0
            )
        `;
        db.query(createTableQuery, (err, result) => {
            if (err) console.error("Error creando tabla reseñas:", err);
            else console.log("✅ Tabla RESENAS verificada/creada.");
        });
    }
});

// ==========================================
//           RUTAS DE AUTENTICACIÓN
// ==========================================

// 1. REGISTRO
app.post('/register', async (req, res) => {
    try {
        const { token, nombre, email, password } = req.body;
        if (!token || !nombre || !email || !password) {
            return res.json({ success: false, message: "Datos incompletos" });
        }

        const hash = await bcrypt.hash(password, 10);
        const sql = "INSERT INTO USUARIO (token_usuario, nombre, correo_electronico, contrasena_cifrada) VALUES (?, ?, ?, ?)";
        
        db.query(sql, [token, nombre, email, hash], (err, result) => {
            if (err) {
                console.error(err);
                return res.json({ success: false, message: "El correo ya está registrado." });
            }
            res.json({ success: true, message: "Usuario registrado" });
        });
    } catch (e) {
        res.json({ success: false, message: e.message });
    }
});

// 2. LOGIN
app.post('/login', (req, res) => {
    const { email, password } = req.body;
    
    const sql = "SELECT * FROM USUARIO WHERE correo_electronico = ?";
    
    db.query(sql, [email], async (err, results) => {
        if (err) {
            return res.json({ success: false, message: err.message });
        }
        if (results.length === 0) {
            return res.json({ success: false, message: "Correo o contraseña incorrectos" });
        }

        const user = results[0];
        const match = await bcrypt.compare(password, user.contrasena_cifrada);

        if (match) {
            res.json({
                success: true,
                message: "Login exitoso",
                data: {
                    id_usuario: user.id_usuario,
                    nombre: user.nombre,
                    token: user.token_usuario
                }
            });
        } else {
            res.json({ success: false, message: "Correo o contraseña incorrectos" });
        }
    });
});

// ==========================================
//           RUTAS DE PERFIL
// ==========================================

app.get('/profile', (req, res) => {
    const userId = req.query.id;
    if (!userId) return res.json({ success: false, message: "ID requerido" });

    const sql = `
        SELECT token_usuario, nombre, aportaciones, descripcion, ruta_foto,
        DATE_FORMAT(fecha_union, '%d/%m/%Y') as fecha_formateada 
        FROM USUARIO WHERE id_usuario = ?
    `;

    db.query(sql, [userId], (err, results) => {
        if (err || results.length === 0) return res.json({ success: false, message: "Usuario no encontrado" });
        const user = results[0];
        res.json({
            success: true,
            data: {
                token: user.token_usuario,
                nombre: user.nombre,
                aportaciones: user.aportaciones,
                descripcion: user.descripcion || "¡Hola! Aún no he escrito una descripción.",
                fecha_union: user.fecha_formateada,
                ruta_foto: user.ruta_foto
            }
        });
    });
});

app.post('/update_description', (req, res) => {
    const { id_usuario, descripcion } = req.body;
    const sql = "UPDATE USUARIO SET descripcion = ? WHERE id_usuario = ?";
    db.query(sql, [descripcion, id_usuario], (err, result) => {
        if (err) return res.json({ success: false, message: err.message });
        res.json({ success: true, message: "Actualizado" });
    });
});

app.post('/upload_profile_picture', upload.single('image'), (req, res) => {
    const { id_usuario, token } = req.body;
    const file = req.file;

    if (!file || !id_usuario || !token) {
        return res.json({ success: false, message: "Faltan datos o archivo" });
    }

    const ext = path.extname(file.originalname);
    const newFilename = `${token}${ext}`; 
    
    const oldPath = path.join(uploadDir, file.filename);
    const newPath = path.join(uploadDir, newFilename);

    try {
        if (fs.existsSync(newPath)) {
            fs.unlinkSync(newPath);
        }
        
        fs.renameSync(oldPath, newPath);

        const fileUrl = `http://localhost:3000/uploads/${newFilename}`;

        const sql = "UPDATE USUARIO SET ruta_foto = ? WHERE id_usuario = ?";
        db.query(sql, [fileUrl, id_usuario], (err, result) => {
            if (err) return res.json({ success: false, message: err.message });
            
            res.json({ 
                success: true, 
                message: "Foto actualizada", 
                data: { url: fileUrl } 
            });
        });

    } catch (error) {
        res.json({ success: false, message: "Error al procesar imagen: " + error.message });
    }
});

// ==========================================
//           RUTAS DE TIENDAS (AÑADIDO)
// ==========================================

app.get('/stores', (req, res) => {
    const sql = `
        SELECT 
            id_tienda AS id, 
            nombre AS title, 
            4 AS rating, 
            'vinilos, música, tienda' AS tags, 
            ruta_foto AS imagePath, 
            descripcion AS description,
            localizacion AS location -- <--- AÑADIMOS ESTO
        FROM TIENDA
    `;
    db.query(sql, (err, result) => {
        if (err) return res.json({ success: false, message: err.message });
        res.json({ success: true, data: result });
    });
});

// ==========================================
//           RUTAS DE RESEÑAS 
// ==========================================

app.get('/reviews', (req, res) => {
    const idTienda = req.query.id_tienda; 
    const sql = "SELECT * FROM RESENAS WHERE id_tienda = ?";
    db.query(sql, [idTienda], (err, result) => {
        if (err) return res.status(500).send({ success: false, message: 'Error' });
        res.send({ success: true, data: result });
    });
});

app.post('/add_review', (req, res) => {
    const { id_tienda, id_usuario, text, rating } = req.body;
    const sql = "INSERT INTO RESENAS (id_tienda, id_usuario, texto, valoracion, likes, dislikes) VALUES (?, ?, ?, ?, 0, 0)";
    db.query(sql, [id_tienda, id_usuario, text, rating], (err, result) => {
        if (err) return res.status(500).send({ message: 'Error al guardar en BD' });
        res.send({ success: true, message: 'Reseña guardada correctamente' });
    });
});

// INICIAR SERVIDOR
app.listen(3000, () => {
    console.log('🚀 Servidor MySQL corriendo en http://localhost:3000');
});