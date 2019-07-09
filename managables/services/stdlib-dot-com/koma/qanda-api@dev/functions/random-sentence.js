const nlp = require('compromise');
const _ = require('underscore');


/**
* Get a random sentence from provided text. 
* @returns {object}
*/
module.exports = async (text = "") => {  
  var sentencesDoc = nlp(text, {allowedTags: []}).sentences();
  
  sentences = sentencesDoc.list.map(ts => {
    return ts.terms.map(t =>{
      return t.text
    });
  });
  
  if(sentences.length === 0) {
    return {error: true, message: 'No sentences found'};
  }


  function calculateRandomIndex(items) {
    return Math.floor(Math.random()*items.length)
  }

  let randomIndex = calculateRandomIndex(sentences);
  let sentence = sentences[randomIndex]
  let tries = 0;
  while(sentence.length < 5 && tries < 5) {
    randomIndex = calculateRandomIndex(sentences);
    sentence = sentences[randomIndex]
    tries++;
  }
  
  if(sentence.length < 5) {
    return {error: true, message: 'No sentence with more than 5 words found'};
  }

  let sentencesBefore = [sentences[randomIndex-1].join(' ')];
  let sentencesAfter = [sentences[randomIndex+1].join(' ')];

  joinedSentence = sentence.join(' ');
   return {
    error: false,
    result: joinedSentence,
    surroundingSentences: {
      before: sentencesBefore,
      after: sentencesAfter
    }
  };
};
