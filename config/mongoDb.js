// db.js
const { MongoClient } = require("mongodb");

const uri = "mongodb+srv://varniah26_db_user:hyGDWENMrC2YKSHN@supermarket.jkfvm3z.mongodb.net/?retryWrites=true&w=majority&appName=supermarket"
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
