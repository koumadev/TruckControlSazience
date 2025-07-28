const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const initDB = require("./config/db");
const departRoutes = require("./routes/departRoute");
const arriveeRoutes = require("./routes/arriveeRoute");

const app = express();
const PORT = 3000;

app.use(cors({ origin: "*" }));
app.use(bodyParser.json());

initDB()
  .then((database) => {
    const departController = require("./controllers/departController");
    const arriveeController = require("./controllers/arriveeController");

    departController.setDB(database);
    arriveeController.setDB(database);

    app.use("/api", departRoutes);
    app.use("/api", arriveeRoutes);

    app.listen(PORT, () => {
      console.log(`Serveur API sur http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Erreur DB:", err);
  });
