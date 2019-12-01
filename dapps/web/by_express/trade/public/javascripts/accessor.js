var ZTIMES = ZTIMES || {};

ZTIMES.ACCESSOR = {
  web3Js: null,
  xAddressContract: null,
  instance: null,
  init: async function(){
    if((typeof window.ethereum !== 'undefined')||(typeof window.web3 !== 'undefined')){
      const provider = window['ethereum'] || window.web3.currentProvider;
      this.web3Js = new Web3(provider);
      ethereum.autoRefreshOnNetworkChange = false;
      const accounts = await ethereum.enable()
      console.log(accounts);
      console.log("isMetaMask : " + ethereum.isMetaMask);
      console.log("networkVersion : " + ethereum.networkVersion);
      console.log("selectedAddress : " + ethereum.selectedAddress);
    }
    else{
      console.log("MetaMask is not valid.");
    }
  },
  GetAddress: function(){
    const xAddressSelf = ethereum.selectedAddress;
    console.log(xAddressSelf);
    return xAddressSelf;
  },
  GetContractAddress: function(){
    console.log(this.xAddressContract);
    return this.xAddressContract;
  },
  GetContract: function(){
    const contractJson = this.getContractJson();
    const contractABI = contractJson["abi"];
    const networkId = ethereum.networkVersion;
    this.xAddressContract = contractJson["networks"][networkId].address;
    this.instance = new this.web3Js.eth.Contract(contractABI,this.xAddressContract);
    return this.instance;
  },
  getContractJson: function(){
    // @note: abiJson_xxxx.js is required.
    return AbiJson;
  },
  ContractCall: async function(strMethod,...params){
    let result = "";
    const method = this.getMethod(strMethod);
    const payload = this.getPayload(params);
    const applyMethod = method.apply(this,params);
    const applyCall = applyMethod.call.apply(this,payload);
    await applyCall.then(function(ret){
      result = ret;
    });
    return result;
  },
  ContractSend: async function(strMethod,...params){
    const method = this.getMethod(strMethod);
    const payload = this.getPayload(params);
    const applyMethod = method.apply(this,params);
    if(payload === undefined){
      await applyMethod.send().on("error",function(error){
        console.log(error);
      });
    }
    else{
      await applyMethod.send(payload).on("error",function(error){
        console.log(error);
      });
    }
  },
  getMethod: function(strMethod){
    const method = this.instance.methods[strMethod];
    return method;
  },
  getPayload: function(params){
    const paramsLast = params.slice(-1)[0];
    const type = Object.prototype.toString.call(paramsLast);
    if(type === "[object Object]"){   // pairs
      const payload = params.pop();
      return payload;
    }
    else{
      return undefined;
    }
  },
  names: {},
  GetName: function(xAddress){
    if(this.names[xAddress] === undefined){
      const namesLen = Object.keys(this.names).length;
      this.names[xAddress] = 'name' + namesLen;
    }
    const name = this.names[xAddress];
    console.log(name);
    return name;
  },
};
