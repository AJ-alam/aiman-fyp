const authRoutes = require("../routes/auth.routes");
const adminRoutes = require("../routes/admin.routes");

const registerRoutes = (app) => {
  app.use("/api/auth", authRoutes);

  // 🔥 REQUIRED
  app.use("/api/admin", adminRoutes);
};

module.exports = { registerRoutes };