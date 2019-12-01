const LoomLocal = function(){
  const { readFileSync } = require('fs');
  const LoomTruffleProvider = require('loom-truffle-provider');
  const chainId = 'default';
  const writeUrl = 'http://127.0.0.1:46658/rpc';
  const readUrl = 'http://127.0.0.1:46658/query';
  const privateKey = readFileSync('./privKey_loomLocal','utf-8');
  this.Provider = new LoomTruffleProvider(chainId,writeUrl,readUrl,privateKey);
  this.Provider.createExtraAccounts(5);
}
const loomLocal = new LoomLocal();

module.exports = {
  networks: {
    loom: {
      provider: loomLocal.Provider,
      network_id: '*',
    },
    loom2: {
      provider: loomLocal.Provider,
      network_id: '*',
//      from: '0x...',
    },
    ganache: {
      host: "127.0.0.1",
      port: 7545,
      network_id: 5777,
    },
    ganache2: {
      host: "127.0.0.1",
      port: 7545,
      network_id: 5777,
//      from: '0x...',
    }
  },
  mocha: {
  },
  compilers: {
    solc: {
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
}
