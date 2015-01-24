var express = require('express');
var router = express.Router();
var formidable = require('formidable');
var util = require('util');
var uuid = require('node-uuid');
var exec = require('child_process').exec;
var fs = require('fs');
var Q = require('q');

var moveFileAsync = function(src, dest) {
  var deferred = Q.defer();
  exec('mv ' + src + ' ' + dest, function(err, stdout, stderr) {
    deferred.resolve();
  });
  return deferred.promise;
}

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'verilog_test' });
});

router.post('/', function(req, res) {
	req.file('files').upload({dirname: './uploads'},function (err, uploadedFiles){
	  if (err) return res.send(500, err);
	  var session_id = uuid.v1();
	  exec('mkdir ./uploads/' + session_id);

    var promises = [];

	  for(var i = 0; i < uploadedFiles.length; i++) {
	  	//exec('mv ' + uploadedFiles[i].fd + ' ./uploads/' + session_id + '/' + uploadedFiles[i].filename);
      promises.push(moveFileAsync(uploadedFiles[i].fd, './uploads/' + session_id + '/' + uploadedFiles[i].filename));
	  }

    Q.all(promises).then(function() {
      var currentTime = new Date().toString();
      var logFile = currentTime + '.txt';
      var logStream = fs.createWriteStream('logs/' + logFile, {flags: 'a'});

      exec('cd rvp && perl ./rvp_test.pl ../uploads/' + session_id + '/*.v', function(err, stdout, stderr) {
        logStream.write(stdout);
        return res.render('result', { result: stdout });
      });
    });
    
	});
});

module.exports = router;
