const express = require("express");
const router = express.Router();
const { addDepart, getAllDeparts } = require("../controllers/departController");

router.post("/depart", addDepart);
router.get("/departs", getAllDeparts);

module.exports = router;
