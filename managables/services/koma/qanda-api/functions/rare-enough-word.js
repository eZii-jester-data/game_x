const lib = require('lib');
// const l2nadb = require('./log-to-natural-database');

/**
* Get random words form the provided text.
* @returns {any}
*/
module.exports = async function(word = "") {
  //TODO: make database work again, natural db neeeds hosting
  
  // return "test";

//   let queryMin = {
//     "resource": "WordFrequency",
//     "minColumn": "count"
//   };
// 
//   let lessUsedWordCount = parseInt(
//     (await lib[`koma.natural-db[@dev].min`](queryMin))
//     ['result']
//     [0]
//   );
// 
//   let queryWordCount = {
//     resource: 'WordFrequency',
//     filter: 'word_normal',
//     filterValue: word
//   };
// 
//   let wordUsedCountQueryResult = (
//     (await lib[`koma.natural-db[@dev].show`](queryWordCount))
//     ['result']
//   );
// 
//   if (wordUsedCountQueryResult.length === 0) return true;
// 
//   let wordUsedCount = parseInt(wordUsedCountQueryResult[0][2]);
// 
//   return (wordUsedCount < (lessUsedWordCount + 10));
return word.length > 2;
}
