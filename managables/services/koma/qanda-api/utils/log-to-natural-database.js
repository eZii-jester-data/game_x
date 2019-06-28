const lib = require('lib');

module.exports = async function(textToLog) {
  await lib[`koma.natural-db[@dev].add`]({
    resource: 'Logs',
    data: {logged_text: textToLog},
    token: "eyJhbGciOiJIUzI1NiJ9.eyJwcm9qZWN0X2lkIjoyMiwiZXhwIjoxNTYwMzU0ODM3fQ.jghaYoFOiMDWLQNNBZAWXYLE40DPwtMd5AN8-JyFpCI",
    db: 46
  });
}