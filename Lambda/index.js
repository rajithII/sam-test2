var time = require('time');
exports.GreetingLambda = (event, context, callback) => {
	    var currentTime = new time.Date(); 
	    currentTime.setTimezone("America/Los_Angeles");
	    callback(null, {
		            statusCode: '200',
		            body: 'The Time In Texas is: ' + currentTime.toString(),
		        });
};
