// db.js
const { MongoClient } = require("mongodb");

const uri = "mongodb+srv://vasandarajdilan64:DjNe4Ji5kLLDNos4@sensor1.i1lcqso.mongodb.net/?retryWrites=true&w=majority&appName=sensor1"; // replace with your connection string
const client = new MongoClient(uri, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

let dbInstance;

async function connectDB() {
  if (!dbInstance) {
    await client.connect();
    console.log("✅ Connected to MongoDB");
    dbInstance = client.db("supermarket");
  }
  return dbInstance;
}

module.exports = connectDB;
