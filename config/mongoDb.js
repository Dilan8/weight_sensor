// mongoDb.js
const { MongoClient } = require("mongodb");

// Replace the hosts below with your actual shard hostnames from Atlas
const hosts = [
  "ac-solayw0-shard-00-00.jkfvm3z.mongodb.net:27017",
  "ac-solayw0-shard-00-01.jkfvm3z.mongodb.net:27017",
  "ac-solayw0-shard-00-02.jkfvm3z.mongodb.net:27017"
];

const username = "varniah26_db_user";
const password = "hyGDWENMrC2YKSHN";
const dbName = "supermarket";
const replicaSet = "atlas-8c75aw-shard-0";

// Construct URI using all hosts
const uri = `mongodb://${username}:${password}@${hosts.join(",")}/?replicaSet=${replicaSet}&authSource=admin&retryWrites=true&w=majority`;

// MongoClient options
const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  tls: true, // ensure TLS is used
  tlsAllowInvalidCertificates: false // set true only for local testing if needed
});

let dbInstance;

async function connectDB() {
  if (!dbInstance) {
    try {
      await client.connect();
      console.log("✅ Connected to MongoDB");
      dbInstance = client.db(dbName);
    } catch (err) {
      console.error("❌ MongoDB Connection Error:", err);
      throw err;
    }
  }
  return dbInstance;
}

module.exports = connectDB;
