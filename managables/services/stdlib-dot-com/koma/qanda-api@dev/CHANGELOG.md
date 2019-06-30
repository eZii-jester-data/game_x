# Changelog


## 0.0.8

### random-words

Bugfixes:

* Added a `uniq` parameter to allow finding only unique random words in the provided text. The default value is `true`.
    * Uniqueness of a word is determined by it's normalized form, provided by the compromise nlp package

* Added an `excludes` parameter facilitating the exlcusion of words by their normalized value provided by the compromise nlp package

* Leading and trailing colons are stripped now


### black-out-random-word

* Leading and trailing colons are stripped from the blacked out word now