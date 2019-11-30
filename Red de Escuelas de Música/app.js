const express = require('express');
const router = express.Router();
const mysql = require('mysql');
const path = require('path');
const ejs = require('ejs');
const bodyParser = require('body-parser');
const fs = require('file-system');
const compression = require('compression');
const helmet = require('helmet');

// ----------------------Creating SQL Connection---------------------------------

const db = mysql.createConnection({
    multipleStatements: true,
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'repertoriored',
    dateStrings: true
});

//-------------------------------Connection---------------------------
db.connect((err) => {
    if (err) {
        console.log(err);
        return;
    }
    console.log("Mysql connection successful");
});

//-----------------------------Creating server---------------------
const app = express();
app.use(helmet());
app.use(compression());
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json()); // body en formato json
app.use('/public', express.static(__dirname + "/public"));
app.use(express.static('public'));
app.set('view engine', 'ejs'); // set the view engine to ejs


//-------------------- Ver Formularios ---------------------------

app.get('/view/compositor', (req, res) => {

    let sql = "SELECT * FROM pais";

    db.query(sql, (err, paises) => {
        if (err) {
            console.log(err);
            return
        }

        sql = "SELECT * FROM periodo";
        db.query(sql, (err, periodos) => {
            if (err) {
                console.log(err);
                return
            }

            res.render("compositorForm.ejs", { paises, periodos });
        });
    })
});

app.get("/view/obra", (req, res) => {

    let sql = "SELECT ID,Compositor FROM compositor";

    db.query(sql, (err, Compositores) => {
        if (err) {
            console.log(err);
            return
        }

        sql = "SELECT ID,Tonalidad FROM tonalidad";

        db.query(sql, (err, Tonalidades) => {
            if (err) {
                console.log(err);
                return
            }

            res.render("ObraForm.ejs", { Compositores, Tonalidades });
        })
    })
});

app.get("/view/consulta", (req, res) => {

    let sql1 = 'SELECT DISTINCT compositor.Pais, compositor.Periodo, pais.Pais, periodo.Periodo \
    FROM compositor \
    JOIN pais ON compositor.Pais = pais.ID \
    INNER JOIN periodo ON compositor.Periodo = periodo.ID';

    let sql2 = 'SELECT obra.*, compositor.Compositor, tonalidad.Tonalidad \
    FROM obra \
    INNER JOIN compositor ON obra.Compositor = compositor.ID \
    INNER JOIN tonalidad ON obra.Tonalidad = tonalidad.ID';

    let sql = sql1 + ";" + sql2;

    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        let data = {
            compositor: result[0],
            obra: result[1]
        }

        res.render("consulta.ejs", data);
    })
});
// --------------------- Insertar Datos ---------------------

app.post("/agregar/compositor", (req, res) => {
    let compositor = req.body.nombre;
    let pais = req.body.pais;
    let periodo = req.body.periodo;
    let descripcion = req.body.descripcion;

    let sql = `SELECT ID FROM pais WHERE pais = '${pais}'`;

    db.query(sql, (err, idPais) => {
        if (err) {
            console.log(err);
            return;
        }

        sql = `SELECT ID FROM periodo WHERE periodo = '${periodo}'`;

        db.query(sql, (err, idPeriodo) => {
            if (err) {
                console.log(err);
                return;
            }

            sql = `INSERT INTO compositor (Compositor,Pais,Periodo,Descripcion) VALUES ('${compositor}',${idPais[0].ID},${idPeriodo[0].ID},'${descripcion}')`;
            db.query(sql, (err, result) => {
                if (err) {
                    console.log(err);
                    return;
                }

                res.redirect("/view/compositor");
            });
        });
    });
});

app.post("/agregar/obra", (req, res) => {

    let obra = req.body.nombre;
    let compositor = req.body.compositor;
    let tonalidad = req.body.tonalidad;
    let nivel = req.body.nivel;

    let esArreglo;
    req.body.esArreglo ? esArreglo = 1 : esArreglo = 0;

    let sql1 = `SELECT ID FROM compositor WHERE compositor = '${compositor}'`;
    let sql2 = `SELECT ID FROM tonalidad WHERE tonalidad = '${tonalidad}'`;

    db.query(`${sql1}; ${sql2}`, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        let idComp = result[0][0].ID;
        let idTon = result[1][0].ID;

        sql1 = `INSERT INTO obra (Obra, Compositor, Tonalidad, Nivel, EsArreglo) VALUES ('${obra}', ${idComp}, ${idTon}, '${nivel}', ${esArreglo})`;
        db.query(sql1, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            let dir = `./Obras/${nivel}/${obra}`;

            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir);
            }
            res.redirect("/view/obra")
        });
    });
});

// ---------------------------------- Formularios Edición de Registros ------------------------------------

app.get("/view/edit/compositor/:id", (req, res) => {

    let id = req.params.id;

    let sql = `SELECT * FROM compositor WHERE ID = ${id}`;

    db.query(sql, (err, compositor) => {
        if (err) {
            console.log(err);
            return;
        }

        let sql1 = `SELECT Pais FROM pais`;
        let sql2 = `SELECT Periodo FROM periodo`;
        sql = sql1 + " ; " + sql2;

        db.query(sql, (err, result) => {

            if (err) {
                console.log(err);
                return;
            }

            let data = {
                Compositor: compositor,
                Result: result
            }

            res.render("editCompForm", data);
        });
    });
});

app.get("/view/edit/obra/:id", (req, res) => {

    let sql = `SELECT obra.*, compositor.Compositor, tonalidad.Tonalidad \
    FROM obra \
    INNER JOIN compositor ON obra.Compositor = compositor.ID \
    INNER JOIN tonalidad ON obra.Tonalidad = tonalidad.ID \
    WHERE obra.ID = ${req.params.id}`;

    db.query(sql, (err, obra) => {
        if (err) {
            console.log(err);
            return;
        }

        sql = "SELECT Compositor FROM compositor";

        db.query(sql, (err, compositor) => {
            if (err) {
                console.log(err);
                return;
            }

            sql = "SELECT Tonalidad FROM tonalidad";

            db.query(sql, (err, tonalidad) => {
                if (err) {
                    console.log(err);
                    return;
                }

                let result = {
                    result: obra,
                    compositor: compositor,
                    tonalidad: tonalidad
                }

                res.render("editObraForm", result);
            });
        });
    });
})
// --------------------------- Ver en Tablas ------------------------

app.get('/table/compositor', (req, res) => {

    let sql = 'SELECT compositor.*, pais.Pais, periodo.Periodo \
    FROM compositor \
    INNER JOIN pais ON compositor.Pais = pais.ID \
    INNER JOIN periodo ON compositor.Periodo = periodo.ID';

    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        res.render("compositores.ejs", { result });
    });
});

app.post('/table/compositor/avanzado', (req, res) => {

    let nombre = req.body.nombre;
    let pais = req.body.pais;
    let periodo = req.body.periodo;

    let c = 0;
    let sql = `SELECT compositor.*, pais.Pais, periodo.Periodo \
    FROM compositor \
    INNER JOIN pais ON pais.ID = compositor.Pais \
    INNER JOIN periodo ON periodo.ID = compositor.Periodo`;

    if (pais) {
        if (c === 0) {
            sql += " WHERE";
            c++;
        }
        sql += ` pais.Pais = '${pais}'`
    }
    if (periodo) {
        if (c === 0) {
            sql += " WHERE";
            c++;
        }else{
            sql += " AND";
        }

        sql += ` periodo.Periodo = '${periodo}'`
    }

    if (nombre) {
        if (c === 0) {
            sql += " WHERE";
        }else{
            sql += " AND";
        }

        sql += ` compositor.Compositor LIKE '%${nombre}%'`;
    }
    

    console.log(sql);
    db.query(sql, (err, result) => {
        console.log(result);

        res.render("compositores.ejs", { result });
    })
});

app.get("/table/obra", (req, res) => {

    let sql = 'SELECT obra.*, compositor.Compositor, tonalidad.Tonalidad \
    FROM obra \
    INNER JOIN compositor ON obra.Compositor = compositor.ID \
    INNER JOIN tonalidad ON obra.Tonalidad = tonalidad.ID';

    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        result.forEach(element => {
            element.EsArreglo === 0 ? element.EsArreglo = "No" : element.EsArreglo = "Si";
        });

        res.render("obras", { result });
    });

});

app.post("/table/obra/avanzado", (req, res) => {
    
    console.log(req.body);

    let compositor = req.body.compositor;
    let tonalidad = req.body.tonalidad;
    let nivel = req.body.nivel;

    let sql = "SELECT obra.*, tonalidad.Tonalidad, compositor.Compositor \
    FROM obra \
    INNER JOIN compositor ON compositor.ID = obra.Compositor \
    INNER JOIN tonalidad ON tonalidad.ID = obra.Tonalidad"
    
    let c = 0;
    if (tonalidad) {
        if (c === 0) {
            sql += " WHERE";
            c++;
        }
        sql += ` tonalidad.Tonalidad = '${tonalidad}'`
    }
    if (nivel) {
        if (c === 0) {
            sql += " WHERE";
            c++;
        }else{
            sql += " AND";
        }

        sql += ` obra.Nivel = '${nivel}'`
    }
    if (compositor) {
        if (c === 0) {
            sql += " WHERE";
            c++;
        }else{
            sql += " AND";
        }

        sql += ` compositor.Compositor = '${compositor}'`
    }

    db.query(sql, (err,result) => {
        if(err){
            console.log(err.message);
            console.log(err.sql);
            return;
        }

        result.forEach(element => {
            element.EsArreglo === 0 ? element.EsArreglo = "No" : element.EsArreglo = "Si";
        });

        console.log(result);
        res.render("obras", { result });
    })
});
// ---------------------------- Editar Registros ---------------------

app.post("/edit/obra/:id", (req, res) => {

    let id = req.params.id;

    let sql1 = `SELECT ID FROM compositor WHERE Compositor = '${req.body.compositor}'`;
    let sql2 = `SELECT ID FROM tonalidad WHERE Tonalidad = '${req.body.tonalidad}'`;
    let sql = sql1 + " ; " + sql2;

    let esArreglo;

    req.body.esArreglo ? esArreglo = 1 : esArreglo = 0;
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        let data = {
            Obra: req.body.nombre,
            Compositor: result[0][0].ID,
            Tonalidad: result[1][0].ID,
            Nivel: req.body.nivel,
            esArreglo: esArreglo
        }

        sql = `UPDATE obra SET ? WHERE ID = ${ id } `;

        db.query(sql, data, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            res.redirect("/table/obra");
        });
    });

});

// -------------------------------------- Eliminar Registros -------------------------------------

app.post("/delete/:table/:id", (req, res) => {

    let id = req.params.id;
    let table = req.params.table;
    let sql;

    if (table === "obra") {

        sql = `SELECT Obra, Nivel FROM obra WHERE ID = ${ id } `;
        console.log(sql);
        db.query(sql, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            console.log(result);
            let dir = `./ Obras / ${ result[0].Nivel } /${result[0].Obra}`;

    console.log(dir);

    deleteFolderRecursive(dir);
})
    }

sql = `DELETE FROM ${table} WHERE ID = ${id}`;

db.query(sql, (err, result) => {
    if (err) {
        console.log(err);
        return;
    }

    res.redirect(`/table/${table}`);
});
});

const deleteFolderRecursive = function (path) {
    if (fs.existsSync(path)) {
        fs.readdirSync(path).forEach((file, index) => {
            const curPath = Path.join(path, file);
            if (fs.lstatSync(curPath).isDirectory()) { // recurse
                deleteFolderRecursive(curPath);
            } else { // delete file
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(path);
    }
};

// -------------------------------- PDF ----------------------------

app.get("/pdf/:id", (req, res) => {

    let id = req.params.id;

    let sql = `SELECT Obra, Nivel FROM obra WHERE ID = ${id}`;

    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        let dir = `./Obras/${result[0].Nivel}/${result[0].Obra}/${result[0].Obra}.pdf`;

        try {
            res.download(dir);
        }
        catch (err) {
            console.error();
        }

    });
});

app.listen(3000, '0.0.0.0');
console.log('Node server running on port 3000');