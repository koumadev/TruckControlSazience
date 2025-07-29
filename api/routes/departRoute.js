const express = require("express");
const router = express.Router();
const departController = require("../controllers/departController");

// Ajouter un départ
router.post("/departs", departController.addDepart);

// Récupérer tous les départs
router.get("/departs", departController.getAllDeparts);

router.get("/incoherences", departController.getIncoherences);

// Récupérer un départ par ID
router.get("/departs/en-cours", departController.getDepartsEnCours);
router.get("/departs/:id", departController.getDepartById);

module.exports = router;
