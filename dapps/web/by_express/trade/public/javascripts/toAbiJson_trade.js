function lcfirst(inText){
  const outText = inText.charAt(0).toLowerCase() + inText.slice(1);
  return outText;
}
function toAbi(){
  const fs = require('fs');
  const contractName = "Trade";
  const contractNameLower = lcfirst(contractName);
  const pathJson = "/home/zombie/dapps/deploy/by_truffle/build/contracts/" + contractName + ".json";
  const inText = fs.readFileSync(pathJson,{encoding:"utf-8"});
  const outText = "const AbiJson = " + inText;
  const apiJson = "/home/zombie/dapps/web/by_express/" + contractNameLower + "/public/javascripts/abiJson_" + contractNameLower + ".js";
  fs.writeFileSync(apiJson,outText,{encoding:"utf-8"});
  console.log("Output : " + apiJson);
}
toAbi();
