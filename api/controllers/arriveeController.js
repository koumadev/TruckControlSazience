let db;

const setDB = (database) => {
  db = database;
};

// 1. Récupérer un départ par immatriculation
const getDepartByImmatriculation = async (req, res) => {
  const { immatriculation } = req.params;
  try {
    const [rows] = await db.execute(
      `SELECT id, immatriculation, conducteur, site_destination, type_chargement
       FROM departs
       WHERE immatriculation = ?
       ORDER BY date_depart DESC, heure_depart DESC
       LIMIT 1`,
      [immatriculation]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: "Aucun départ trouvé" });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

// 2. Mettre à jour l’arrivée
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
        .json({ error: "Départ non trouvé ou quantité déja enregistrée." });
    }

    res.json({ message: "Arrivée enregistrée avec succès." });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur." });
  }
};

module.exports = { setDB, getDepartByImmatriculation, updateArrivee };
