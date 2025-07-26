// server.js
const express = require("express");
const bodyParser = require("body-parser");
const initDB = require("./db");

const app = express();
const PORT = 3000;

app.use(bodyParser.json());

let db;

// Lancer serveur et initialiser DB
initDB()
  .then((database) => {
    db = database;

    // Endpoint POST pour enregistrer un départ
    app.post("/api/depart", async (req, res) => {
      const {
        immatriculation,
        conducteur,
        siteDestination,
        typeChargement,
        quantite,
        dateHeure,
      } = req.body;

      if (!immatriculation || !conducteur) {
        return res
          .status(400)
          .json({ error: "Immatriculation et conducteur obligatoires." });
      }

      try {
        const [result] = await db.execute(
          `INSERT INTO depart (immatriculation, conducteur, site_destination, type_chargement, quantite, date_heure)
         VALUES (?, ?, ?, ?, ?, ?)`,
          [
            immatriculation,
            conducteur,
            siteDestination,
            typeChargement,
            quantite,
            dateHeure,
          ]
        );
        res
          .status(201)
          .json({ message: "Départ enregistré", id: result.insertId });
      } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Erreur serveur." });
      }
    });

    // Endpoint GET pour lister tous les départs
    app.get("/api/departs", async (req, res) => {
      try {
        const [rows] = await db.execute(
          "SELECT * FROM depart ORDER BY date_heure DESC"
        );
        res.json(rows);
      } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Erreur serveur." });
      }
    });

    // Lancer serveur
    app.listen(PORT, () =>
      console.log(`Serveur API sur http://localhost:${PORT}`)
    );
  })
  .catch((err) => {
    console.error("Erreur DB:", err);
  });
