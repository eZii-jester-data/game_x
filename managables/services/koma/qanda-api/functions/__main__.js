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
    text: response.rs.result,
    numberOfWords: 4,
    similarTo: blackedOutDict.termNormal
  });

  let choices = [];

  // let statisticsPromises = [];
  _.each(randomWordsFromArticle, (randomWord) => {
    choices.push({correctAnswer: false, word: randomWord.word});
    // statisticsPromises.push(countWord(randomWord.termNormal));
  });

  choices.push({correctAnswer: true, word: blackedOutDict.blackedOutWord});
  // statisticsPromises.push(countWord(blackedOutDict.termNormal));

  // await Promise.all(statisticsPromises);

  choices = _.shuffle(choices);

  return {articleTitle: response.p.title, wikipediaId: response.p.wikipediaId, sentence: blackedOutDict, choices: choices};
}

async function randomSentenceErrorProne(language, source, context) {
  var text;
  if (source === 'wikipedia') {
    let page = await lib[`${context.service.identifier}.random-wikipedia-page`]({language: language});
    text = page.text;
  } else {
    text = "This could be coming from airtable."
  }
  
  let randomSentence = await lib[`${context.service.identifier}.random-sentence`]({text: text});

  if(randomSentence.error === true) {
    return randomSentenceErrorProne(language, context);
  } else {
    return {p: page, rs: randomSentence};
  }
}
