ZTIMES.BLOCKCHAIN = {
  init: function(){
    console.log("ZTIMES.BLOCKCHAIN.init()");
    const contractName = "Trade";
    this.myContract = ZTIMES.ACCESSOR.GetContract();
    console.log(contractName);
    this.xAddressSelf = ZTIMES.ACCESSOR.GetAddress();
    this.ORDER_SELL = 0;
    this.ORDER_BUY = 1;
  },
  test: async function(){
    console.log("ZTIMES.BLOCKCHAIN.test()");
  },
  CreateWalletCurrency: async function(){
    await ZTIMES.ACCESSOR.ContractSend('CreateWalletCurrency',{from:this.xAddressSelf});
  },
  SellOrder: async function(price,amount){
    const fee = 240;
    await ZTIMES.ACCESSOR.ContractSend('SellOrder',price,amount,{from:this.xAddressSelf,value:fee});
  },
  BuyOrder: async function(price,amount){
    const fee = 240;
    await ZTIMES.ACCESSOR.ContractSend('BuyOrder',price,amount,{from:this.xAddressSelf,value:fee});
  },
  DoAgreement: async function(){
    await ZTIMES.ACCESSOR.ContractSend('DoAgreement',{from:this.xAddressSelf});
  },
  ShowCurrencyBalance: async function(){
    const result = await ZTIMES.ACCESSOR.ContractCall('GetCurrencyBalance',ZTIMES.BLOCKCHAIN.xAddressSelf,{from:ZTIMES.BLOCKCHAIN.xAddressSelf});
    ZTIMES.GUI.editInnerText('iCurrencyBalanceUSD',result.balance_USD);
    ZTIMES.GUI.editInnerText('iCurrencyBalanceEUR',result.balance_EUR);
  },
  ShowSellOrder: function(){
    ZTIMES.GUI.initValueText('iSellOrderList');
    ZTIMES.BLOCKCHAIN.showOrder(ZTIMES.BLOCKCHAIN.ORDER_SELL);
  },
  ShowBuyOrder: function(){
    ZTIMES.GUI.initValueText('iBuyOrderList');
    ZTIMES.BLOCKCHAIN.showOrder(ZTIMES.BLOCKCHAIN.ORDER_BUY);
  },
  showOrder: async function(orderKind){
    const OrderList = await ZTIMES.ACCESSOR.ContractCall('s_orderLists',orderKind,{from:ZTIMES.BLOCKCHAIN.xAddressSelf});
    const OrderListLen = OrderList.length;
    let xOrder = OrderList.xFirst;
    let orderItem;
    for(let cnt=0; cnt<OrderListLen; cnt+=1){
      orderItem = await ZTIMES.ACCESSOR.ContractCall('GetOrder',xOrder,{from:ZTIMES.BLOCKCHAIN.xAddressSelf});
      ZTIMES.BLOCKCHAIN.outputOrderList(orderKind,orderItem);
      while(1){
        xOrder = orderItem.xLink_QUEUE_NEXT;
        if(xOrder === '0x0000000000000000000000000000000000000000'){
          break;
        }
        orderItem = await ZTIMES.ACCESSOR.ContractCall('GetOrder',xOrder,{from:ZTIMES.BLOCKCHAIN.xAddressSelf});
        ZTIMES.BLOCKCHAIN.outputOrderList(orderKind,orderItem);
      }
      xOrder = orderItem.xLink_LIST_NEXT;
      if(xOrder === '0x0000000000000000000000000000000000000000'){
        break;
      }
    }
  },
  outputOrderList: async function(orderKind,orderItem){
    let prefix = '';
    let id = '';
    if(orderKind == ZTIMES.BLOCKCHAIN.ORDER_SELL){
      prefix = 'SELL';
      id = 'iSellOrderList';
    }
    else if(orderKind == ZTIMES.BLOCKCHAIN.ORDER_BUY){
      prefix = 'BUY';
      id = 'iBuyOrderList';
    }
    const text = prefix + ': ' + orderItem.price10000 + ' ' + orderItem.amount;
    ZTIMES.GUI.insertValueText(id,text);
  },
  ShowAgreement: async function(){
    ZTIMES.GUI.initValueText('iAgreementList');
    const agreeInfoListLen = await ZTIMES.ACCESSOR.ContractCall('GetAgreeInfoLen');
    for(let cnt=0; cnt<agreeInfoListLen; cnt+=1){
      let index = agreeInfoListLen - cnt - 1;
      const agreeInfo = await ZTIMES.ACCESSOR.ContractCall('s_agreeInfoList',index);
      const text
       = 'Sell: ' + agreeInfo.priceSell + ' ' + agreeInfo.amountDone
       + '  Buy:' + agreeInfo.priceBuy + ' ' + agreeInfo.amountDone;
      ZTIMES.GUI.insertValueText('iAgreementList',text);
    }
  },
}

ZTIMES.GUI = {
  init: function(){
    console.log("ZTIMES.GUI.init()");
    this.isTouch = 'ontouchend' in document;
    this.setup();
  },
  test: function(){
    console.log("ZTIMES.GUI.test()");
  },
  setup: function(){
    this.addKeyUp('iCreateWalletCurrency',function(){
      ZTIMES.BLOCKCHAIN.CreateWalletCurrency();
      setTimeout(ZTIMES.BLOCKCHAIN.ShowCurrencyBalance,10000);
    },false);
    this.addKeyUp('iSellOrder',function(){
      const orderPatten = ZTIMES.GUI.getOrderPattern();
      ZTIMES.BLOCKCHAIN.SellOrder(orderPatten.price,orderPatten.amount);
      setTimeout(ZTIMES.BLOCKCHAIN.ShowSellOrder,10000);
      setTimeout(ZTIMES.BLOCKCHAIN.ShowCurrencyBalance,12000);
    },false);
    this.addKeyUp('iBuyOrder',function(){
      const orderPatten = ZTIMES.GUI.getOrderPattern();
      ZTIMES.BLOCKCHAIN.BuyOrder(orderPatten.price,orderPatten.amount);
      setTimeout(ZTIMES.BLOCKCHAIN.ShowBuyOrder,10000);
      setTimeout(ZTIMES.BLOCKCHAIN.ShowCurrencyBalance,12000);
    },false);
    this.addKeyUp('iDoAgreement',function(){
      ZTIMES.BLOCKCHAIN.DoAgreement();
      ZTIMES.GUI.refresh();
    },false);
    this.addKeyUp('iGetCurrencyBalance',function(){
      ZTIMES.BLOCKCHAIN.ShowCurrencyBalance();
    },false);
    this.addKeyUp('iShowSellOrder',function(){
      ZTIMES.BLOCKCHAIN.ShowSellOrder();
    },false);
    this.addKeyUp('iShowBuyOrder',function(){
      ZTIMES.BLOCKCHAIN.ShowBuyOrder();
    },false);
    this.addKeyUp('iShowAgreement',function(){
      ZTIMES.BLOCKCHAIN.ShowAgreement();
    },false);
    this.addKeyUp('iRefresh',function(){
      ZTIMES.GUI.refresh();
    },false);
    this.refresh();
  },
  refresh: function(){
    setTimeout(ZTIMES.BLOCKCHAIN.ShowAgreement,10000);
    setTimeout(ZTIMES.BLOCKCHAIN.ShowSellOrder,11000);
    setTimeout(ZTIMES.BLOCKCHAIN.ShowBuyOrder,12000);
    setTimeout(ZTIMES.BLOCKCHAIN.ShowCurrencyBalance,13000);
  },
  getOrderPattern: function(){
    const selected = document.getElementById('iOrderPatterns').elements.nTab.value;
    const orderPatterns = {
      'vTag101':{price:10, amount:1},
      'vTag102':{price:10, amount:2},
      'vTag103':{price:10, amount:3},
      'vTag111':{price:11, amount:1},
      'vTag112':{price:11, amount:2},
      'vTag113':{price:11, amount:3},
    };
    const orderPattern = orderPatterns[selected];
    return orderPattern;
  },
  keyDown: function(){
    return (this.isTouch ? 'touchstart':'mousedown');
  },
  keyMove: function(){
    return (this.isTouch ? 'touchmove':'mousemove');
  },
  keyUp: function(){
    return (this.isTouch ? 'touchend':'mouseup');
  },
  addKeyUp: function(id,action){
    try{
      document.getElementById(id).addEventListener(this.keyUp(),action,false);
    }
    catch(e){ console.log(e); }
    finally{}
  },
  addChange: function(id,action){
    try{
      document.getElementById(id).addEventListener('change',action,false);
    }
    catch(e){ console.log(e); }
    finally{}
  },
  editInnerText: function(id,text){
    try{
      document.getElementById(id).innerText = text;
    }
    catch(e){ console.log(e); }
    finally{}
  },
  initValueText: function(id){
    try{
      document.getElementById(id).value = '';
    }
    catch(e){ console.log(e); }
    finally{}
  },
  insertValueText: function(id,text){
    try{
      document.getElementById(id).value += text + '\n';
    }
    catch(e){ console.log(e); }
    finally{}
  },
}

ZTIMES.RUN = {
  init: function(){
    ZTIMES.ACCESSOR.init();
    ZTIMES.BLOCKCHAIN.init();
    ZTIMES.GUI.init();
  },
  test: async function(){
    ZTIMES.BLOCKCHAIN.test();
    ZTIMES.GUI.test();
  },
};

// https://metamask.github.io/metamask-docs/
window.addEventListener('load',async function(){
  ZTIMES.RUN.init();
  ZTIMES.RUN.test();
});
ethereum.on('accountsChanged',function(accounts){
  console.log("changed : " + accounts);
});
