const mongoose = require("mongoose");

async function getSubscribedAgentIds() {
  try {
    const collection = mongoose.connection.db.collection("subscriptions");
    const now = new Date();
    const subscriptions = await collection.find({
      status: "active",
      expiry_date: { $gt: now },
    }).toArray();
    const agentIds = subscriptions.map((s) => s.agent_id.toString());
    return agentIds;
  } catch (err) {
    console.error("Subscription fetch error:", err.message);
    return [];
  }
}

async function fetchRelevantPackages(userQuery) {
  try {
    const q = userQuery.toLowerCase();
    const collection = mongoose.connection.db.collection("packages");
    const subscribedAgentIds = await getSubscribedAgentIds();
    if (subscribedAgentIds.length === 0) return null;

    const query = {};
    if (q.includes("murree")) query.location = /murree/i;
    else if (q.includes("lahore")) query.location = /lahore/i;
    else query.$or = [{ location: /murree/i }, { location: /lahore/i }];
    if (q.includes("discount") || q.includes("discounted") || q.includes("offer")) {
  query.hasDiscount = true;
}
if (q.includes("featured") || q.includes("popular") || q.includes("top")) {
  query.isFeatured = true;
}
if (q.includes("cheap") || q.includes("budget") || q.includes("affordable")) {
  query.price = { $lte: 15000 };
}

    query.isActive = true;
    const packages = await collection.find(query).limit(10).toArray();
    const filtered = packages.filter((pkg) => 
      subscribedAgentIds.includes(pkg.agentId?.toString())
    );
    console.log(`📦 Packages after subscription filter: ${filtered.length}`);
    if (!filtered.length) return null;

    return filtered.map((pkg, i) => `Package ${i + 1}:
  Title: ${pkg.title}
  Location: ${pkg.location}
  Price: PKR ${pkg.price}
  Duration: ${pkg.duration}
  Description: ${pkg.description || ""}`).join("\n\n");
  } catch (err) {
    console.error("Package fetch error:", err.message);
    return null;
  }
}

async function fetchPackagesForDisplay(userQuery) {
  try {
    const q = userQuery.toLowerCase();
    const collection = mongoose.connection.db.collection("packages");
    const subscribedAgentIds = await getSubscribedAgentIds();
    if (subscribedAgentIds.length === 0) return [];

    const query = {};
    if (q.includes("murree")) query.location = /murree/i;
    else if (q.includes("lahore")) query.location = /lahore/i;
    else query.$or = [{ location: /murree/i }, { location: /lahore/i }];
    if (q.includes("discount") || q.includes("discounted") || q.includes("offer")) {
  query.hasDiscount = true;
}
if (q.includes("featured") || q.includes("popular") || q.includes("top")) {
  query.isFeatured = true;
}
if (q.includes("cheap") || q.includes("budget") || q.includes("affordable")) {
  query.price = { $lte: 15000 };
}

    query.isActive = true;
    const packages = await collection.find(query).limit(10).toArray();
    const filtered = packages.filter((pkg) => 
      subscribedAgentIds.includes(pkg.agentId?.toString())
    );
    return filtered;
  } catch (err) {
    console.error("Display package fetch error:", err.message);
    return [];
  }
}

module.exports = { fetchRelevantPackages, fetchPackagesForDisplay };