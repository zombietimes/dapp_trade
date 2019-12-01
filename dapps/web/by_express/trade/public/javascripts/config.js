const CONFIG = function(){
//  this.JS_KIND = "server_side";  // node.js
  this.JS_KIND = "client_side";  // html-css-javascript
  this.WEB3_KIND = "ganache";
//  this.WEB3_KIND = "metamask";
//  this.WEB3_KIND = "loom";
//  this.WEB3_KIND = "other";
//  this.PRIVATEKEY = "";  // the private key of the account[0] for signing in : 0x...
}
const config = new CONFIG();

if(config.JS_KIND === "server_side"){
  module.exports = config;
}

