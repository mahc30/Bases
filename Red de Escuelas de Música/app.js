const express = require('express');
const router = express.Router();
const mysql = require('mysql');
const path = require('path');
const ejs = require('ejs');
const bodyParser = require('body-parser');
const fs = require('file-system');

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
app.use(express.urlencoded({ extended: false }));
app.use('/public', express.static(__dirname + "/public"));
app.use(express.static('public'));
app.use(bodyParser.json()); // body en formato json
app.use(bodyParser.urlencoded({ extended: false })); //body formulario
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

    let sql = 'SELECT Compositor.*, pais.Pais, periodo.Periodo \
    FROM compositor \
    INNER JOIN pais ON compositor.Pais = pais.ID \
    INNER JOIN periodo ON compositor.Periodo = periodo.ID';

    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        console.log(result);

        res.render("compositores.ejs", { result });
    });
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

// ---------------------------------- Edición de Registros ----------------------------------

app.post("/edit/comp/:id", (req, res) => {

    let id = req.params.id;
    let sql1 = `SELECT ID FROM pais WHERE Pais ='${req.body.pais}'`;
    let sql2 = `SELECT ID FROM periodo WHERE Periodo = '${req.body.periodo}'`
    let sql = sql1 + " ; " + sql2;

    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        let data = {
            Compositor: req.body.nombre,
            Pais: result[0][0].ID,
            Periodo: result[1][0].ID,
            Descripcion: req.body.descripcion
        }
        sql = `UPDATE compositor SET ? WHERE id = ${id}`;

        db.query(sql, data, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            res.redirect("/table/compositor")
        });
    });
});

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

        sql = `UPDATE obra SET ? WHERE ID = ${id}`;

        db.query(sql, data, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            res.redirect("/table/obra");
        })
    });
    
});

// -------------------------------------- Eliminar Registros -------------------------------------

app.post("/delete/:table/:id", (req, res) => {

    let id = req.params.id;
    let table = req.params.table;
    let sql;

    if (table === "obra") {

        sql = `SELECT Obra, Nivel FROM obra WHERE ID = ${id}`;
        console.log(sql);
        db.query(sql, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            console.log(result);
            let dir = `./Obras/${result[0].Nivel}/${result[0].Obra}`;

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
app.listen(3000, '127.0.0.1');
console.log('Node server running on port 3000');
