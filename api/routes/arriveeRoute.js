const express = require("express");
const router = express.Router();
const arriveeController = require("../controllers/arriveeController");

router.get(
  "/arrivees/:immatriculation",
  arriveeController.getDepartByImmatriculation
);
router.patch("/arrivees/:id", arriveeController.updateArrivee);

module.exports = router;
