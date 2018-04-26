var time = require('time');
exports.FunctionName = (event, context, callback) => {
	    var currentTime = new time.Date(); 
	    currentTime.setTimezone("America/Los_Angeles");
	    callback(null, {
		            statusCode: '200',
		            body: 'The Time In Los_Angeles is: ' + currentTime.toString(),
		        });
};
