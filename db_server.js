const express = require('express');
const app = express();
const port = 3000;

const crochetQuotes = [
  { id: 1, quote: "Crochê é a arte de criar com amor e paciência." },
  { id: 2, quote: "Cada ponto é uma jornada, não apenas um destino." },
  { id: 3, quote: "Com crochê, criamos arte com linhas e sonhos." },
  { id: 4, quote: "Crochê: onde a imaginação encontra o fio." },
  { id: 5, quote: "A beleza do crochê está no cuidado com cada detalhe." }
];

// Rota para retornar uma frase aleatória
app.get('/crochetQuotes/random', (req, res) => {
  const randomIndex = Math.floor(Math.random() * crochetQuotes.length);
  const randomQuote = crochetQuotes[randomIndex];
  res.json(randomQuote);
});

app.listen(port, () => {
  console.log(`Servidor rodando em http://localhost:${port}`);
});
