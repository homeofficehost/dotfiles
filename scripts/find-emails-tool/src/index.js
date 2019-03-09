const getStdin = require('get-stdin');
const Knwl = require("knwl.js");

const knwlInstance = new Knwl('english');

getStdin().then(str => {
	knwlInstance.init(str);
	console.log(JSON.stringify(knwlInstance.get('emails')))
});
