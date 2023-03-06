var express = require('express');
var app = express();
const PG_CONFIG = {
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: 5432,
}

app.get('/', function(req, res){
   res.send("Hello world!");
});

app.get('/db_healthcheck', async function(_, res) {
  const { Pool } = require('pg')
  const pool = new Pool(PG_CONFIG)
  const text = `
    CREATE TABLE IF NOT EXISTS "users" (
	    "id" SERIAL,
	    "name" VARCHAR(100) NOT NULL,
	    "role" VARCHAR(15) NOT NULL,
	    PRIMARY KEY ("id")
    );`;
  try {
    await pool.query(text)
  } catch (error) {
    console.log('already created')
    console.log(error)
  }

  const d_res = await pool.query('SELECT * FROM users LIMIT 5')
  pool.end()
  return res.send(d_res)
})

app.listen(3000, "0.0.0.0", 10, () => {
  console.log('app is running in `http://localhost:3000/`...');
});
