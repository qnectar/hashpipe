// Generated by CoffeeScript 1.11.1
(function() {
  var fs, path, resolvePath;

  fs = require('fs');

  path = require('path');

  resolvePath = function(string) {
    if (string.substr(0, 1) === '~') {
      string = process.env.HOME + string.substr(1);
    }
    return path.resolve(string);
  };

  exports.cat = function(inp, args, ctx, cb) {
    var filename;
    filename = resolvePath(args[0]);
    return fs.readFile(filename, function(err, buffer) {
      return cb(err, buffer.toString());
    });
  };

  exports['cat-stream'] = function(inp, args, ctx, cb) {
    var filename;
    filename = resolvePath(args[0]);
    return cb(null, fs.createReadStream(filename));
  };

  exports.write = function(inp, args, ctx, cb) {
    var filename;
    filename = resolvePath(args[0]);
    return fs.writeFile(filename, inp, function(err) {
      return cb(null, inp);
    });
  };

  exports.ls = function(inp, args, ctx, cb) {
    var filename;
    filename = resolvePath(args[0] || '.');
    return fs.readdir(filename, cb);
  };

  exports.cd = function(inp, args, ctx, cb) {
    var dirname;
    dirname = resolvePath(args[0]);
    process.chdir(dirname);
    return cb(null, {
      success: true,
      dir: process.cwd()
    });
  };

  exports.mv = function(inp, args, ctx, cb) {
    var filename0, filename1;
    filename0 = resolvePath(args[0]);
    filename1 = resolvePath(args[1]);
    return fs.rename(filename0, filename1, function(err) {
      return cb(null, {
        success: err == null
      });
    });
  };

}).call(this);