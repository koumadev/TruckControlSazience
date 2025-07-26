// db.js
const mysql = require("mysql2/promise");

const DB_NAME = "control_gma";

async function initDB() {
  const connection = await mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "root", // change avec ton mot de passe MySQL
  });

  // Création base si elle n'existe pas
  await connection.query(`CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\``);
  console.log(`Base "${DB_NAME}" prête.`);

  // Connexion à la base
  const db = await mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "root",
    database: DB_NAME,
  });

  // Création table si elle n'existe pas
  await db.query(`
  CREATE TABLE IF NOT EXISTS departs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    immatriculation VARCHAR(20) NOT NULL,
    conducteur VARCHAR(50) NOT NULL,
    site_destination VARCHAR(50),
    type_chargement VARCHAR(50),
    quantite_depart INT,
    quantite_arrivee INT DEFAULT NULL,
    date_depart DATE NOT NULL,
    heure_depart TIME NOT NULL,
    date_arrivee DATE DEFAULT NULL,
    heure_arrivee TIME DEFAULT NULL
  )
`);

  console.log('Table "departs" prête.');
  return db;
}

module.exports = initDB;
