// mongoDb.js
const { MongoClient } = require("mongodb");

const dbName = "supermarket";
const uri = process.env.MONGO_URI || "mongodb://docdb_user:DocdbPass123@sensor-docdb-cluster.cluster-czueamasy3z1.ap-southeast-2.docdb.amazonaws.com:27017/supermarket?tls=true&tlsCAFile=/usr/src/app/global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false";

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
