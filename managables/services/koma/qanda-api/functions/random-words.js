const _ = require('underscore');
const nlp = require('compromise');
const w2v = require("word2vec-pure-js")
// const logToNaturalDatabase = require("../utils/log-to-natural-database")
w2v.load("./word2vec-models/test-text8-vector.bin")

/**
* Get random words form the provided text.
* @returns {array}
*/
module.exports = async (text = "", numberOfWords = 1, uniq = true, excludes = [], wordTypes = [], similarTo = "") => {
   let relatedTerms = _.shuffle(w2v.getSimilarWords(similarTo, numberOfWords ** 2));  
  // TODO: figure out why word2vec-pure-js returns gibberish,possible encoding issue, observed once before, no idea how it went away
  // These encoding issues seem to surface when deploying from code.stdlib.com, almost definitely it's because the file is loaded into the RAM and corrupted this way.

  console.log(similarTo);
  console.log(relatedTerms);

  let terms = nlp(relatedTerms.join(" ")).out("terms");
  
  if(uniq === true) {
    terms = _.uniq(terms, 'normal');
  }


  terms = _.filter(terms, function(term) {
	  return _.contains(term.tags, 'Noun');
  });
  
  let relatedTermsEnrichedByCompromiseNlp = [];
  for(i=0;i<numberOfWords;i++) {
      let randIndex = Math.floor(Math.random()*terms.length);
      relatedTermsEnrichedByCompromiseNlp.push(terms[randIndex]);
      delete terms[randIndex];
  }  

  console.log(relatedTermsEnrichedByCompromiseNlp);

  let randomWords = _.map(relatedTermsEnrichedByCompromiseNlp, (term, index)=> {
    console.log(term, index);
    return {word: term.text, termNormal: term.normal};
  });

  return randomWords;
};
