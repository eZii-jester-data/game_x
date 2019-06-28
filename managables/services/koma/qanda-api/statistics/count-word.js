const lib = require('lib');

module.exports = async function(word) {
  await lib[`koma.natural-db[@dev].create-or-increment`]({
    resource: 'WordFrequency',
    whereColumn: 'word_normal',
    whereValue: word,
    incrementColumn: 'count',
    token: process.env.NATURAL_DB_TOKEN,
    db: 19
  }); 
}