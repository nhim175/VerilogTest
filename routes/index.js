var express = require('express');
var router = express.Router();
var formidable = require('formidable');
var util = require('util');
var uuid = require('node-uuid');
var exec = require('child_process').exec;

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});

router.post('/', function(req, res) {
	req.file('files').upload({dirname: '/Users/thinhpham/Downloads/rvp/client/uploads'},function (err, uploadedFiles){
	  if (err) return res.send(500, err);
	  var session_id = uuid.v1();
	  exec('mkdir ./uploads/' + session_id);
	  for(var i = 0; i < uploadedFiles.length; i++) {
	  	exec('mv ' + uploadedFiles[i].fd + ' ./uploads/' + session_id + '/' + uploadedFiles[i].filename);
	  }
	  exec('cd rvp && perl ./rvp_test.pl ../uploads/' + session_id + '/*.v', function(err, stdout, stderr) {
		  return res.render('result', { result: stdout });
	  });
	});
});

module.exports = router;
