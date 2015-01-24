var exec = require('cordova/exec')

var videoEditor = function () {
    this.name = "videoEditor";
};

videoEditor.prototype.edit = function (succ,error,option) {
	return exec(succ, error, "VideoEditor", "edit",[option]);
};

module.exports = new videoEditor();
