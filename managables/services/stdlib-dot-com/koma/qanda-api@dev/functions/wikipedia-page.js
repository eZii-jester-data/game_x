const axios = require('axios');
const _ = require('underscore');
const sanitizeHtml = require('sanitize-html');
const decodeHtml = require('decode-html');

/**
* Random wikipedia article contents
* @returns {object}
*/
module.exports = async (language = 'en', pageIds = []) => {
  var apiResponse;
  if(pageIds) {
    apiResponse = await axios.get(randomWikipediaArticleApiEndpoint(language));
  } else {
    apiResponse = await axios.get(artByPageId(pageIds[0]));
  }
  
  var page = _.values(apiResponse.data['query']['pages'])[0];
  var response = {};
  
  response['text'] = decodeHtml(sanitizeHtml(page['extract'], {allowedTags: []}));
  response['title'] = page['title'];
  response['wikipediaId'] = page['pageid'];

  return response;
};

function randomWikipediaArticleApiEndpoint(language) {
  return `https://${language}.wikipedia.org/w/api.php?format=json&action=query&generator=random&grnnamespace=0&prop=extracts&grnlimit=1`;
  //return `https://en.wikipedia.org/w/api.php?format=json&action=query&titles=World_history&grnnamespace=0&prop=extracts&grnlimit=1`;
}

function artByPageId(pageId) {
  return `https://en.wikipedia.org/w/api.php?format=json&action=query&pageids=${pageId}&grnnamespace=0&prop=extracts&grnlimit=1`
}