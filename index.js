const express = require('express');

const app = express();
const port = 3000;

console.log(eval("1+1"));
console.log(eval("1+1"));
app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
