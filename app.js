var express = require('express');
var app = express();

app.get('/', function(req, res){
   res.send("Hello world!");
});

app.listen(3000, "0.0.0.0", 10, () => {
  console.log('app is running in `http://localhost:3000/`...');
});
