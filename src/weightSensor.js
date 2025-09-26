const mqtt = require("mqtt");
const fs = require("fs");
const connectDB = require("../config/mongoDb"); // MongoDB connection
const brokerUrl = process.env.MQTT_BROKER || "tcp://mqtt-service:1883";

// MQTT connection
const client = mqtt.connect(brokerUrl); // change to localhost if testing locally

// Load mock shelf data
let shelves = JSON.parse(fs.readFileSync("./data/mockData.json", "utf8"));
let shelfCollection;

// Initialize MongoDB collection
connectDB().then(db => {
  shelfCollection = db.collection("shelfEvents");
});

// Save/update shelf event to MongoDB
async function saveEventToMongo(eventPayload) {
  if (!shelfCollection) return;
  try {
    await shelfCollection.updateOne(
      { shelf_id: eventPayload.shelf_id, product_id: eventPayload.product_id },
      { $set: eventPayload },
      { upsert: true }
    );
    console.log(`💾 Saved event to MongoDB for ${eventPayload.shelf_id}`);
  } catch (err) {
    console.error("❌ MongoDB Error:", err);
  }
}

// Function to determine stock type
function getStockType(shelf) {
  if (shelf.total_item_count < shelf.threshold_count) return "Low Stock";
  if (shelf.total_item_count >= shelf.max_item_count) return "Max Capacity";
  return "Normal Stock";
}

// Add items to shelf
function addItem(shelf, count = 1) {
  shelf.total_item_count = Math.min(shelf.max_item_count, shelf.total_item_count + count);
  shelf.last_action = "added";
  shelf.last_count = count;
  shelf.stock_type = getStockType(shelf);

  console.log(`✅ Added ${count} item(s) to ${shelf.shelf_id}. New count: ${shelf.total_item_count}`);
  checkAlerts(shelf);
}

// Remove items from shelf
function removeItem(shelf, count = 1) {
  shelf.total_item_count = Math.max(0, shelf.total_item_count - count);
  shelf.last_action = "removed";
  shelf.last_count = count;
  shelf.stock_type = getStockType(shelf);

  console.log(`⚠️ Removed ${count} item(s) from ${shelf.shelf_id}. New count: ${shelf.total_item_count}`);
  checkAlerts(shelf);
}

// Check for low stock or max capacity alerts
function checkAlerts(shelf) {
  if (shelf.stock_type === "Low Stock" || shelf.stock_type === "Max Capacity") {
    const alertMsg = {
      type: shelf.stock_type,
      store_id: shelf.store_id,
      shelf_id: shelf.shelf_id,
      product_name: shelf.product_name,
      current_count: shelf.total_item_count,
      last_action: shelf.last_action,
      last_count: shelf.last_count,
      timestamp: new Date().toISOString()
    };
    console.log(`⚠️ ${shelf.stock_type} Alert:`, JSON.stringify(alertMsg, null, 2));
    client.publish("supermarket/alerts", JSON.stringify(alertMsg));
  }
}

// Publish full shelves state to MQTT & MongoDB
function publishShelves() {
  const payload = shelves.map(shelf => ({
    store_id: shelf.store_id,
    shelf_id: shelf.shelf_id,
    product_id: shelf.product_id,
    product_name: shelf.product_name,
    total_item_count: shelf.total_item_count,
    new_weight_kg: (shelf.total_item_count * shelf.unit_weight_g) / 1000,
    last_action: shelf.last_action || null,
    last_count: shelf.last_count || 0,
    stock_type: shelf.stock_type || "Normal Stock",
    timestamp: new Date().toISOString()
  }));

  // Publish to MQTT
  client.publish("supermarket/events", JSON.stringify(payload));
  console.log("📦 Published full shelves JSON:\n", JSON.stringify(payload, null, 2));

  // Save each shelf to MongoDB
  payload.forEach(eventPayload => saveEventToMongo(eventPayload));
}

// Simulate random add/remove events
function simulateShelves() {
  shelves.forEach(shelf => {
    const count = Math.ceil(Math.random() * 5); // 1–5 items
    if (Math.random() > 0.5) removeItem(shelf, count);
    else addItem(shelf, count);
  });

  publishShelves();
}

// Start simulation every 5 seconds
setInterval(simulateShelves, 10000);
