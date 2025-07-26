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
    CREATE TABLE IF NOT EXISTS depart (
      id INT AUTO_INCREMENT PRIMARY KEY,
      immatriculation VARCHAR(20) NOT NULL,
      conducteur VARCHAR(50) NOT NULL,
      site_destination VARCHAR(50),
      type_chargement VARCHAR(50),
      quantite INT,
      date_heure DATETIME
    )
  `);

  console.log('Table "depart" prête.');
  return db;
}

module.exports = initDB;
