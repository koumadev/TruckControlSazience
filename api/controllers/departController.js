let db;

const setDB = (database) => {
  db = database;
};

const addDepart = async (req, res) => {
  const {
    immatriculation,
    conducteur,
    siteDestination,
    typeChargement,
    quantiteDepart,
    dateDepart,
    heureDepart,
  } = req.body;

  if (!immatriculation || !conducteur) {
    return res
      .status(400)
      .json({ error: "Immatriculation et conducteur obligatoires." });
  }

  try {
    const [result] = await db.execute(
      `INSERT INTO departs
       (immatriculation, conducteur, site_destination, type_chargement, quantite_depart, date_depart, heure_depart)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        immatriculation,
        conducteur,
        siteDestination,
        typeChargement,
        quantiteDepart,
        dateDepart,
        heureDepart,
      ]
    );
    res.status(201).json({ message: "Départ enregistré", id: result.insertId });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

const getAllDeparts = async (req, res) => {
  try {
    const [rows] = await db.execute(
      "SELECT * FROM departs ORDER BY date_depart DESC, heure_depart DESC"
    );
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

module.exports = { setDB, addDepart, getAllDeparts };
