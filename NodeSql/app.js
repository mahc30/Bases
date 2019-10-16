const express = require('express');
const mysql = require('mysql');

//Creating SQL Connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'nodemysql'
});

//Connection
db.connect((err) => {
    if (err) {
        console.log(err);
        return;
    }
    console.log("Mysql connection successful");
});

//Creating server
const app = express();

//Creating DB
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

//Creating Table
app.get('/createInstrumentsTable', (req, res) => {
    let sql = 'CREATE TABLE instruments(id int AUTO_INCREMENT, instrument VARCHAR(255), type VARCHAR(255), PRIMARY KEY(id))';
    db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send('instruments Table Created');
    });

});

//Insert instrument
app.get('/addInstrument', (req, res) => {
    let instrument = {
        instrument: 'Violin',
        type: 'Cuerda Frotada'
    }
    let sql = 'INSERT INTO instruments SET ?'
    let query = db.query(sql, instrument, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        res.send('Instrument added');
    });
});

//Select instruments
app.get('/getInstruments', (req, res) => {

    let sql = 'SELECT * FROM instruments'
    let query = db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }

        res.send('instruments Fetched');
    });
});

//Select Single instrument
app.get('/getInstruments/:id', (req, res) => {
    
    let sql = `SELECT * FROM instruments WHERE id = ${req.params.id}`;
    let query = db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send(`Instrument ${req.params.id} fetched`);
    });
});

//Update Single instrument
app.get('/updateInstruments/:id', (req, res) => {
    
    let newName = 'Updated Title';

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

//Delete Single instrument
app.get('/deleteInstruments/:id', (req, res) => {
    
    let newName = 'Updated Title';

    let sql = `DELETE FROM instruments WHERE id = ${req.params.id}`;
    let query = db.query(sql, (err, result) => {
        if (err) {
            console.log(err);
            return;
        }
        console.log(result);
        res.send(`Instrument ${req.params.id} Deleted`);
    });
});
app.listen('3000', () => {
    console.log("running on 3000");
});