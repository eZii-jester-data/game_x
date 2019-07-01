const lib = require('lib');
const _ = require('underscore');
// const countWord = require('../statistics/count-word.js');

/**
* Qanda question endpoint.
* @returns {object}
*/
module.exports = async (language = "en", source="wikipedia", context) => {
  let response = await randomSentenceErrorProne(language, source, context);

  let blackedOutDict = await lib[`${context.service.identifier}.black-out-random-word`]({sentence: response.rs.result});
  let randomWordsFromArticle = await lib[`${context.service.identifier}.random-words`]({
    similarTo: blackedOutDict.termNormal
  });

  let choices = [];

  _.each(randomWordsFromArticle, (randomWord) => {
    choices.push({correctAnswer: false, word: randomWord.word});
  });

  choices.push({correctAnswer: true, word: blackedOutDict.blackedOutWord});

  choices = _.shuffle(choices);

  return {articleTitle: response.p.title, wikipediaId: response.p.wikipediaId, sentence: blackedOutDict, choices: choices};
}

async function randomSentenceErrorProne(language, source, context) {
  var text;
  var page;
  if (source === 'wikipedia') {
    page = await lib[`${context.service.identifier}.random-wikipedia-page`]({language: language});
    text = page.text;
  } else {
    page = {title: "This will be questions from ocrd images"}
    text = "They were named one of the 10 most innovative companies in education by Fast Company (magazine) in 2013."
  }
  
  let randomSentence = await lib[`${context.service.identifier}.random-sentence`]({text: text});

  if(randomSentence.error === true) {
    return randomSentenceErrorProne(language, source, context);
  } else {
    return {p: page, rs: randomSentence};
  }
}
