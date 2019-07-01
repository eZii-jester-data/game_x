const _ = require('underscore');
const nlp = require('compromise');
const w2v = require("word2vec-pure-js")
w2v.load("./word2vec-models/test-text8-vector.bin")

/**
* Get random words form the provided text.
* @returns {array}
*/
module.exports = async (numberOfWords = 3, similarTo = "") => {
  let relatedTerms = _.shuffle(w2v.getSimilarWords(similarTo, numberOfWords ** 2));  

  let terms = nlp(relatedTerms.join(" ")).out("terms");

  terms = _.uniq(terms, 'normal');

  terms = _.filter(terms, function(term) {
	  return _.contains(term.tags, 'Noun');
  });
  
  let relatedTermsEnrichedByCompromiseNlp = [];
  for(i=0;i<numberOfWords;i++) {
      let randIndex = Math.floor(Math.random()*terms.length);
      relatedTermsEnrichedByCompromiseNlp.push(terms[randIndex]);
      terms.splice(randIndex, 1);
  }  


  let randomWords = _.map(relatedTermsEnrichedByCompromiseNlp, (term, index)=> {
    return {word: term.text, termNormal: term.normal};
  });

  return randomWords;
};
