const _ = require('underscore');
const nlp = require('compromise');
const lib = require('lib');

/**
* Black out a random word in a sentence. 
* @returns {object}
*/
module.exports = async (sentence = "", context) => {
  let sentenceTerms = nlp(sentence).out('terms');

  let sentenceDict = {
    before: "",
    blackedOutWord: undefined,
    after: ""
  };
  
  sentenceTerms = _.filter(sentenceTerms, (term) => {
    return term.normal !== "";
  });
  

  var nounIndices = [];
  for(i = 0; i < sentenceTerms.length; i++) {
	    let term = sentenceTerms[i];
            let isNoun = _.includes(term.tags, 'Noun');
            let isLongerThan2Chars = term.normal.length > 2;

	    if(isNoun && isLongerThan2Chars) {
		    nounIndices.push(i);
	    }
  }

  console.log(nounIndices);


  let blackedOutIndex = _.sample(nounIndices);

  console.log(blackedOutIndex);

  _.each(sentenceTerms, (term, index)=> {   
    if(index < blackedOutIndex) {
      sentenceDict.before += term.text;
      
      if(index !== (blackedOutIndex - 1)) {
        sentenceDict.before += " ";
      }
    } else if(index > blackedOutIndex) {
      sentenceDict.after += term.text;
      
      if((sentenceTerms.length - 1) !== index) {
        sentenceDict.after += " ";
      }
    } else if(index === blackedOutIndex) {
      var termText = term.text;
      
      let specialCharsCharacterClass = '[,\\.\\?!()\\-\\–\/"\\s;:*]';
      let nonWordCharsRegex = new RegExp(`^(${specialCharsCharacterClass}*)(.+?)(${specialCharsCharacterClass}*)$`);
      let matchResult = nonWordCharsRegex.exec(termText);
      
      sentenceDict.termNormal = term.normal;
      sentenceDict.tags = term.tags;
      sentenceDict.before += matchResult[1];
      sentenceDict.blackedOutWord = matchResult[2];
      sentenceDict.after += matchResult[3];
    }
  });
  
  return sentenceDict;
};

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
