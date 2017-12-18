/* eslint-disable  func-names */
/* eslint quote-props: ["error", "consistent"]*/

'use strict';

const Alexa = require('alexa-sdk');

const APP_ID = undefined;  // TODO replace with your app ID (OPTIONAL).

const praisedName = process.env.PRAISED_NAME;
const languageStrings = {
    'ja': {
        translation: {
            PRAISE_WORDS: [
                'すごい',
                '最高',
                '天才',
                '世界一',
                'かっこいい',
            ],
            SKILL_NAME: '褒めるbot',
            GET_PRAISE_MESSAGE: '褒めます: ',
            HELP_MESSAGE: '「褒めて」といいましょう',
            HELP_REPROMPT: '「褒めて」といいましょう',
            STOP_MESSAGE: 'さようなら！いつでも褒めるので呼んでください',
            UNHANDLED_MESSAGE: 'すみません、よく分かりませんでした',
        },
    },
};

const handlers = {
    'LaunchRequest': function () {
        this.emit('GetPraise');
    },
    'SessionEndedRequest': function () {
        this.emit(':tell', this.t('STOP_MESSAGE'));
    },
    'Unhandled': function () {
    },
    'GetPraiseIntent': function () {
        this.emit('GetPraise');
    },
    'GetPraise': function () {
        // Use this.t() to get corresponding language data
        const praiseWords = this.t('PRAISE_WORDS');
        const praiseIndex = Math.floor(Math.random() * praiseWords.length);
        const randomPraise = praiseWords[praiseIndex];

        // Create speech output
        const speechOutput = this.t('GET_PRAISE_MESSAGE') + praisedName + randomPraise;
        const reprompt = this.t('HELP_REPORT');
        this.emit(':ask', speechOutput, reprompt);
    },
    'AMAZON.HelpIntent': function () {
        const speechOutput = this.t('HELP_MESSAGE');
        const reprompt = this.t('HELP_REPORT');
        this.emit(':ask', speechOutput, reprompt);
    },
    'AMAZON.CancelIntent': function () {
        this.emit(':tell', this.t('STOP_MESSAGE'));
    },
    'AMAZON.StopIntent': function () {
        this.emit(':tell', this.t('STOP_MESSAGE'));
    },
};

exports.handler = function (event, context) {
    const alexa = Alexa.handler(event, context);
    alexa.APP_ID = APP_ID;
    alexa.resources = languageStrings;
    alexa.registerHandlers(handlers);
    alexa.execute();
};

