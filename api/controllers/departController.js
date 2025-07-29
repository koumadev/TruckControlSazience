let db;

const setDB = (database) => {
  db = database;
};

// 1. Ajouter un départ (uniquement depuis l'app mobile)
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
       (immatriculation, conducteur, site_destination, type_chargement,
        quantite_depart, date_depart, heure_depart)
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

// 2. Récupérer tous les départs
const getAllDeparts = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT * FROM departs ORDER BY date_depart DESC, heure_depart DESC`
    );
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

// 3. Récupérer un départ par ID
const getDepartById = async (req, res) => {
  const { id } = req.params;
  try {
    const [rows] = await db.execute(`SELECT * FROM departs WHERE id = ?`, [id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: "Départ introuvable." });
    }
    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

// 4. Mettre à jour l’arrivée (quantité arrivée, date et heure automatiques)
const updateArrivee = async (req, res) => {
  const { id } = req.params;
  const { quantiteArrivee } = req.body;

  if (!quantiteArrivee) {
    return res.status(400).json({ error: "Quantité arrivée obligatoire." });
  }

  const now = new Date();
  const dateArrivee = now.toISOString().split("T")[0];
  const heureArrivee = now.toTimeString().split(" ")[0];

  try {
    const [result] = await db.execute(
      `UPDATE departs
       SET quantite_arrivee = ?, date_arrivee = ?, heure_arrivee = ?
       WHERE id = ? AND quantite_arrivee IS NULL`,
      [quantiteArrivee, dateArrivee, heureArrivee, id]
    );

    if (result.affectedRows === 0) {
      return res
        .status(404)
        .json({ error: "Départ non trouvé ou arrivée déjà enregistrée." });
    }

    res.json({ message: "Arrivée enregistrée avec succès." });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

const getIncoherences = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT * FROM departs 
       WHERE quantite_arrivee IS NOT NULL 
       AND quantite_arrivee <> quantite_depart`
    );
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

// Récupérer uniquement les départs en cours (pas encore arrivés)
const getDepartsEnCours = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT * FROM departs 
       WHERE quantite_arrivee IS NULL 
       ORDER BY date_depart DESC, heure_depart DESC`
    );
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

module.exports = {
  setDB,
  addDepart,
  getAllDeparts,
  getDepartById,
  updateArrivee,
  getIncoherences,
  getDepartsEnCours,
};
