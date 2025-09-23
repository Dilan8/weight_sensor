// mongoDb.js
const { MongoClient } = require("mongodb");

const dbName = "supermarket";
const uri = process.env.MONGO_URI || "mongodb://localhost:27017/supermarket"; // local fallback

const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  tls: uri.includes("docdb.amazonaws.com") || uri.includes("mongodb+srv"), // enable TLS for DocumentDB or Atlas
  tlsAllowInvalidCertificates: true, // for DocumentDB self-signed cert
});

let dbInstance;

async function connectDB() {
  if (!dbInstance) {
    try {
      await client.connect();
      console.log("✅ Connected to MongoDB/DocumentDB");
      dbInstance = client.db(dbName);
    } catch (err) {
      console.error("❌ MongoDB/DocumentDB Connection Error:", err);
      throw err;
    }
  }
  return dbInstance;
}

module.exports = connectDB;
