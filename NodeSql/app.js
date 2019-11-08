/*Aquí se maneja la base de datos MySql

            Index
1. Create SQL connection
2. Connection
3. Create Server
4. Create DB
5. Create Tables
    5.1 Instrumentos
    5.2 TiposInstrumento
    5.3 Compositores
    5.4 Pais
    5.5 Tonalidades
    5.6 Obras
    5.7 Géneros

6. Modify Tables
    6.1 Add Foreign Key Columns to Obras
    6.2 Add Foreign Key to Instrumentos from TiposInstrumento
    
7. Insert Items in Table
    7.1 Instrumentos
    7.2 Compositores
    7.3 Tipos de Instrumento
    7.4 Tonalidades
    7.5 Paises
8. Select All Items From Table
9. Select One Item From Table
10. Update One Item From Table
11. Delete One Item From Table
12. Rendering
    12.1 Index/Home Page
*/

const express = require('express');
const router = express.Router();
const mysql = require('mysql');
const path = require('path');
const ejs = require('ejs');
const bodyParser = require('body-parser');
const fs = require('file-system');
// ----------------------Creating SQL Connection---------------------------------

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'nodemysql',
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
// set the view engine to ejs
app.set('view engine', 'ejs');

//----------------------------Creating DB------------------------------
app.get('/createdb', (req, res) => {
    let sql = 'CREATE DATABASE nodemysql';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err)
            return;
        }
        console.log(result);
        res.send('Database Created');
    });
});

//----------------------------Creating Tables----------------------------
app.get('/createInstrumentosTable', (req, res) => {
    let sql = 'CREATE TABLE instrumentos(id int AUTO_INCREMENT, instrumento VARCHAR(255), PRIMARY KEY(id))';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('instruments Table Created');
    });

});

app.get('/createTiposInstrumentoTable', (req, res) => {
    let sql = 'CREATE TABLE tiposInstrumento(id int AUTO_INCREMENT, tipo VARCHAR(255), PRIMARY KEY(id))';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('TiposInstrumento Table Created');
    });
});

app.get('/createCompositoresTable', (req, res) => {
    let sql = 'CREATE TABLE compositores(id int AUTO_INCREMENT, nombre VARCHAR(255), nac DATE, fal DATE, descripcion TEXT, PRIMARY KEY(id))';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('Compositores Table Created');
    });
});

app.get('/createTonalidadesTable', (req, res) => {
    let sql = 'CREATE TABLE tonalidades(id int AUTO_INCREMENT, tonalidad VARCHAR(5), PRIMARY KEY(id))';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('Tonalidades Table Created');
    });
});

app.get('/createPaisTable', (req, res) => {
    let sql = 'CREATE TABLE paises(id int AUTO_INCREMENT, pais VARCHAR(255), PRIMARY KEY(id))';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('Tonalidades Table Created');
    });
});

app.get('/createObrasTable', (req, res) => {
    let sql = 'CREATE TABLE obras(id int AUTO_INCREMENT, nombre VARCHAR(255),año DATE, arreglo BOOLEAN, instrumentos INT, PRIMARY KEY(id), FOREIGN KEY (instrumentos) REFERENCES instrumentos(id))'
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('Obras Table Created');
    });
});

app.get('/createGenerosTable', (req, res) => {
    let sql = 'CREATE TABLE generos(id int AUTO_INCREMENT, genero VARCHAR(255), PRIMARY KEY(id))';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('Generos Table Created');
    });
});

//----------------------------Modify Table----------------------------

app.get('/ModifyObrasTable', (req, res) => {
    let sql = 'ALTER TABLE nodemysql.obras ADD COLUMN tonalidades int DEFAULT(1), ADD FOREIGN KEY (tonalidades) REFERENCES tonalidades(id) ON DELETE CASCADE';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('Obras Table Modified');
    });
});

// EDITAR INSTRUMENTO
app.get('/Modify/instrumentos/:id', (req, res) => {
    let sql = `SELECT * FROM instrumentos WHERE id = ${req.params.id}`;
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        res.redirect(`/editInstForm/${result[0].id}/${result[0].instrumento}`);
    });
});

app.get('/editInstForm/:id/:nombre', (req, res) => {
    let sql = `SELECT instrumentos.id, tiposInstrumento.tipo FROM instrumentos, tiposInstrumento WHERE instrumentos.id = ${req.params.id.replace(':', '')}`;
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        let data = {
            id: result[0].id,
            nombre: req.params.nombre,
            tipo: result[0].tipo,
            tipoid: result[0].tipoid
        }

        res.render(`editInstForm.ejs`, data);
    });
});

app.post('/modinst/:id/', (req, res) => {
    console.log(req.body);
    let newName = req.body.nombre;
    let tipo = req.body.tipo;
    let id = req.params.id;

    let sql = `UPDATE instrumentos SET instrumento = '${newName}', tipo = (SELECT id FROM tiposInstrumento WHERE tipo = '${tipo}') WHERE id=${id}`;
    console.log(sql);
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        console.log(`Instrumento modificado: ${newName}`);
        res.redirect("/getAll/instrumentos/*");
    });
    console.log(sql);
});

//MODIFICAR COMPOSITOR

app.get('/Modify/compositores/:id', (req, res) => {
    let sql = `SELECT * FROM compositores WHERE id = ${req.params.id}`;
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        res.redirect(`/editCompForm/${result[0].id}/${result[0].instrumento}`);
    });
});

app.get('/editCompForm/:id/:nombre', (req, res) => {
    let sql = `SELECT id, nombre, nac, fal, descripcion FROM compositores WHERE id = ${req.params.id.replace(':', '')}`;
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        let data = {
            result: result
        }

        res.render(`editCompForm.ejs`, data);
    });
});

app.post('/modComp/:id/', (req, res) => {
    let id = req.params.id;
    let newName = req.body.nombre;
    let newNac = new Date(req.body.nac).toISOString().slice(0, 19).replace('T', ' ');;
    let newFal = new Date(req.body.fal).toISOString().slice(0, 19).replace('T', ' ');;
    let newDesc = `${req.body.descripcion}`;

    if (validateDates(newNac, newFal)) {
        let data = {
            nombre: newName,
            nac: newNac,
            fal: newFal,
            descripcion: newDesc
        }

        let sql = `UPDATE compositores SET ? WHERE id = ${id}`;
        db.query(sql, data, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            console.log(`Compositor modificado: ${newName}`);
            res.redirect("/getAll/compositores/*");
        });
        console.log(sql);
    }
    else {
        res.redirect(`/ModifY/compositores/${id}`);
    }
});

//----------------------------Insert Data----------------------------
app.post('/addInstrument', (req, res) => {
    var instName = req.body.nombre;
    var tipo = req.body.tipo;

    if (tipo === 'cuerda') {
        tipo = 1;
    }
    else if (tipo === 'viento') {
        tipo = 2;
    }
    else {
        tipo = 3;
    }

    let instrument = {
        instrumento: instName,
        tipo: tipo
    }
    let sql = 'INSERT INTO instrumentos SET ?';
    let query = db.query(sql, instrument, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
    });
    res.sendFile(path.join(__dirname, 'public', '/instrumentoForm.html'));
});

app.post('/addComposer', (req, res) => {
    let nombre = req.body.nombre;
    let nac = req.body.nac;
    let fal = req.body.fal;
    let desc = req.body.descripcion;

    if (validateDates(nac, fal)) {

        let data = {
            nombre: nombre,
            nac: nac,
            fal: fal,
            descripcion: desc
        }

        let sql = 'INSERT INTO compositores SET ?';

        db.query(sql, data, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            console.log("Compositor Agregado");
        });
    }

    res.redirect("/form/compositorForm");

});

var dbmult = mysql.createConnection({
    multipleStatements: true,
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'nodemysql'
});

app.post('/addObra', (req, res) => {
    let nombre = req.body.nombre;
    let esArreglo = req.body.esArreglo;
    let tonalidad = req.body.tonalidad;
    let genero = req.body.genero;
    let compositor = req.body.compositor;

    esArreglo ? esArreglo = "1" : esArreglo = "0";

    let tonsql = "SELECT id FROM tonalidades WHERE tonalidad = '" + tonalidad + "'";

    let gensql = "SELECT id FROM generos WHERE genero = '" + genero + "'";

    let compsql = `SELECT id FROM compositores WHERE nombre = '${compositor}'`;

    let query = dbmult.query(gensql + ';' + tonsql + ';' + compsql, (err, result) => {
        if (err) console.log(err);

        let sql = 'INSERT INTO obras SET ?';
        let data = {
            nombre: nombre,
            arreglo: esArreglo,
            genero: result[0][0].id,
            tonalidad: result[1][0].id,
            compositor: result[2][0].id
        }

        //console.log(data);
        let query = db.query(sql, data, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }

            fs.mkdir("./Obras/Repertorio Orquesta/" + data.nombre,{ recursive: true }, (err, ye) => {
                if(err){
                    console.log(err);
                    return;
                }

                //console.log("Carpeta Creada");
            })
            res.redirect('/view/obra');
        });
    });
});

app.get('/addInstrumentType', (req, res) => {
    let instrument = {
        tipo: 'Percusión'
    }

    let sql = 'INSERT INTO tiposinstrumento SET ?'
    let query = db.query(sql, instrument, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        res.send('Instrument Type added');
    });
});

app.get('/addTonalidades', (req, res) => {
    var tonalidades = ['C', 'F', 'G', 'D', 'A', 'E', 'B', 'Gb', 'Db', 'Ab', 'Eb', 'Bb', 'Am', 'Em', 'Bm', 'C#m', 'C#m', 'G#m', 'Ebm', 'Bbm', 'Fm', 'Cm', 'Gm', 'Dm'];

    for (var t = 0; t < tonalidades.length; t++) {
        let i = tonalidades[t];
        let tonalidad = {
            tonalidad: i
        }
        let sql = 'INSERT INTO tonalidades SET ?'

        let query = db.query(sql, tonalidad, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }
        });
    }

    res.send("Tonalidades added");
});

app.get('/addCountries', (req, res) => {
    var country_list = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Anguilla", "Antigua &amp; Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas"
        , "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia &amp; Herzegovina", "Botswana", "Brazil", "British Virgin Islands"
        , "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Chad", "Chile", "China", "Colombia", "Congo", "Cook Islands", "Costa Rica"
        , "Cote D Ivoire", "Croatia", "Cruise Ship", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea"
        , "Estonia", "Ethiopia", "Falkland Islands", "Faroe Islands", "Fiji", "Finland", "France", "French Polynesia", "French West Indies", "Gabon", "Gambia", "Georgia", "Germany", "Ghana"
        , "Gibraltar", "Greece", "Greenland", "Grenada", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India"
        , "Indonesia", "Iran", "Iraq", "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kuwait", "Kyrgyz Republic", "Laos", "Latvia"
        , "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Mauritania"
        , "Mauritius", "Mexico", "Moldova", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Namibia", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia"
        , "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal"
        , "Puerto Rico", "Qatar", "Reunion", "Romania", "Russia", "Rwanda", "Saint Pierre &amp; Miquelon", "Samoa", "San Marino", "Satellite", "Saudi Arabia", "Senegal", "Serbia", "Seychelles"
        , "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "South Africa", "South Korea", "Spain", "Sri Lanka", "St Kitts &amp; Nevis", "St Lucia", "St Vincent", "St. Lucia", "Sudan"
        , "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor L'Este", "Togo", "Tonga", "Trinidad &amp; Tobago", "Tunisia"
        , "Turkey", "Turkmenistan", "Turks &amp; Caicos", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "United States Minor Outlying Islands", "Uruguay"
        , "Uzbekistan", "Venezuela", "Vietnam", "Virgin Islands (US)", "Yemen", "Zambia", "Zimbabwe"];

    for (let i = 0; i < country_list.length; i++) {

        let country = country_list[i];

        let countryDb = {
            pais: country
        }

        let sql = 'INSERT INTO paises SET ?';

        let query = db.query(sql, countryDb, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }
        });
    }

    res.send("Paises added");
});

app.post('/addgen', (req, res) => {

    let sql = `INSERT INTO generos SET ?`

    let data = {
        genero: req.body.nombre
    };

    db.query(sql, data, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        console.log("Género agregado");
        res.redirect('/form/generoForm');
    });
});
//---------------------------- SELECT QUERY----------------------------
app.get('/getAll/:table/:col', (req, res) => {
    res.redirect(`/view/${req.params.table}/${req.params.col}`);
});



//----------------------------Update Single instrument----------------------------
app.get('/updateInstruments/:id', (req, res) => {

    let newName = req.params.instrument;

    let sql = `UPDATE instruments SET instrument = '${newName}' WHERE id = ${req.params.id}`;
    let query = db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send(`Instrument ${req.params.id} Updated`);
    });
});

//----------------------------Delete Single instrument----------------------------
app.post('/delete/:tabla/:id', (req, res) => {

    let sql = `DELETE FROM ${req.params.tabla} WHERE id = ${req.params.id}`;
    let query = db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        res.redirect(`/view/${req.params.tabla}/*`);
    });
});


app.listen('3000', () => {
    console.log("running on 3000");
});

//----------------------------Render----------------------------

app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname, 'public', '/index.html'));
});

var generos = [];
var tonalidades = [];
var compositores = [];
var instrumentos = [];
var tipos = [];

function setTipo(val) {
    tipos = val;
}

app.get('/view/:table/:col', function (req, res, next) {

    let table = req.params.table;
    let col = req.params.col;

    if (table === "instrumentos") {
        db.query(`SELECT tipo FROM tiposinstrumento`, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }
            setTipo(result);
        });
    }
    else if (table === "obras") {

        let sql = 'SELECT tonalidad FROM tonalidades';
        db.query(sql, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }
            else {
                setValue(result, false, false, false);
            }
        });

        sql = 'SELECT nombre FROM compositores';
        db.query(sql, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }
            else {
                setValue(false, result, false, false);
            }
        });

        sql = 'SELECT instrumento FROM instrumentos';
        db.query(sql, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }
            else {
                setValue(false, false, result);
            }
        });
        sql = 'SELECT genero FROM generos';
        db.query(sql, (err, result) => {
            if (err) {
                console.log(err);
                return;
            }
            else {
                setValue(false, false, false, result);
            }
        });
    }

    let sql = `SELECT ${col} FROM ${table}`;
    let query = db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        //console.log(result);
        //console.log(compositores);
        if (table === "instrumentos") {
            result.forEach(element => {
                element.tipo === 1 ? element.tipo = tipos[0].tipo : '0';
                element.tipo === 2 ? element.tipo = tipos[1].tipo : '0';
                element.tipo === 3 ? element.tipo = tipos[2].tipo : '0';
            });
        } else if (table === "obras") {
            result.forEach(element => {
                //console.log(element.compositor);
                element.arreglo === 0 ? element.arreglo = "No" : element.arreglo = "Si";
                element.tonalidad = tonalidades[element.tonalidad - 1].tonalidad;
                element.genero = generos[element.genero - 1].genero;
                element.compositor = compositores[element.compositor - 5].nombre;
            });
        }

        res.render(`${table}.ejs`, { result: result });
    });

});

app.get('/view/obra', function (req, res, next) {
    let sql = 'SELECT tonalidad FROM tonalidades';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        else {
            setValue(result, false, false, false);
        }
    });

    sql = 'SELECT nombre FROM compositores';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        else {
            setValue(false, result, false, false);
        }
    });

    sql = 'SELECT instrumento FROM instrumentos';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        else {
            setValue(false, false, result);
        }
    });
    sql = 'SELECT genero FROM generos';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        else {
            setValue(false, false, false, result);
        }
    });
    res.render('ObraForm.ejs', { generos: generos, tonalidades: tonalidades, compositores: compositores, instrumentos: instrumentos });

});

function setValue(val1, val2, val3, val4) {
    if (val1) {
        tonalidades = val1;
    }
    else if (val2) {
        compositores = val2;
    } else if (val3) {
        instrumentos = val3;
    } else {
        generos = val4;
    }

    if (val1 && val2 && val3 && val4) {
        console.log(tonalidades);
        console.log(compositores);
        console.log(instrumentos);
    }
}

//----------------------------GetForm----------------------------

app.get('/form/:name', (req, res, next) => {
    var name = req.params.name.concat('.html');
    //    console.log(name);
    if (name === 'obraForm.html') {
        res.redirect('/view/obra')
    }
    res.sendFile(path.join(__dirname, 'public', `/${name}`));
});


function twoDigits(d) {
    if (0 <= d && d < 10) return "0" + d.toString();
    if (-10 < d && d < 0) return "-0" + (-1 * d).toString();
    return d.toString();
}

Date.prototype.toMysqlFormat = function () {
    return this.getUTCFullYear() + "-" + twoDigits(1 + this.getUTCMonth()) + "-" + twoDigits(this.getUTCDate()) + " " + twoDigits(this.getUTCHours()) + ":" + twoDigits(this.getUTCMinutes()) + ":" + twoDigits(this.getUTCSeconds());
};

function validateDates(d1, d2) {
    return (Date.parse(d1) < Date.parse(d2));
}