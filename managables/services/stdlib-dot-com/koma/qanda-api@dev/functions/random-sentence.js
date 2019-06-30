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

  
  let sentence = _.sample(sentences);
  let tries = 0;
  while(sentence.length < 15 && tries < 5) {
    sentence = _.sample(sentences);
    tries++;
  }
  
  if(sentence.length < 15) {
    return {error: true, message: 'No sentence with more than 15 words found'};
  }

  let sentencesBefore = [];
  let sentencesAfter = [];

  
  joinedSentence = sentence.join(' ');
   return {
    error: false,
    result: joinedSentence,
    contextBefore: sentencesBefore,
    contextAfter: sentencesAfter
  };
};
