pragma solidity >= 0.5.0;

contract ItemKey {}

contract Trade {
  // Order
  uint8 private ORDER_SELL = 0;
  uint8 private ORDER_BUY = 1;
  uint8 private LINK_LIST_NEXT = 0;
  uint8 private LINK_QUEUE_NEXT = 1;
  uint8 private LINK_QUEUE_LAST = 2;
  struct Order {
    uint8 orderKind;
    mapping(uint8 => address) xLinks;
    address xOwner;
    uint32 primaryKey;    // price10000
    uint32 amount;
    uint deposit;
    uint timeStamp;
  }
  struct OrderList {
    address xFirst;
    uint32 length;
  }
  mapping(address => Order) public s_orders;
  mapping(uint8 => OrderList) public s_orderLists;
  function newOrderKey() private returns(address orderKey) {
    ItemKey itemKey = new ItemKey();
    orderKey = address(itemKey);
  }
  function createOrder(
    uint8 orderKind,
    uint32 price10000,
    uint32 amount,
    uint deposit
  ) private returns(address orderKey) {
    require(price10000 > 0, "[ERR] createOrder");
    address xOwner = msg.sender;
    orderKey = newOrderKey();
    s_orders[orderKey] = Order({
      orderKind: orderKind,
      xOwner: xOwner,
      primaryKey: price10000,
      amount: amount,
      deposit: deposit,
      timeStamp: now
    });
  }
  function addOrderList(
    uint8 orderKind,
    address orderKeyNew
  ) private {
    address orderKeyListAt = s_orderLists[orderKind].xFirst;
    if(orderKeyListAt == address(0)){
      addOrder_toList(orderKind,orderKeyListAt,orderKeyNew);
      return;
    }
    address orderKeyListPrevious = address(0);
    uint32 listLen = s_orderLists[orderKind].length;
    for(uint32 cnt=0; cnt<listLen; cnt+=1) {
      uint32 primaryKeyAt = s_orders[orderKeyListAt].primaryKey;
      uint32 primaryKeyNew = s_orders[orderKeyNew].primaryKey;
      if(primaryKeyAt == primaryKeyNew){
        addOrder_toQueue(orderKeyListAt,orderKeyNew);
        break;
      }
      if((orderKind == ORDER_SELL)&&(primaryKeyAt > primaryKeyNew)){
        // Ascending list
        addOrder_toList(orderKind,orderKeyListPrevious,orderKeyNew);
        break;
      }
      if((orderKind == ORDER_BUY)&&(primaryKeyAt < primaryKeyNew)){
        // Descending list
        addOrder_toList(orderKind,orderKeyListPrevious,orderKeyNew);
        break;
      }
      orderKeyListPrevious = orderKeyListAt;
      orderKeyListAt = s_orders[orderKeyListAt].xLinks[LINK_LIST_NEXT];
      if(orderKeyListAt == address(0)){
        break;
      }
    }
  }
  function addOrder_toList(
    uint8 orderKind,
    address orderKeyListAt,
    address orderKeyNew
  ) private {
    address orderKeyListNext = address(0);
    if(orderKeyListAt == address(0)){
      orderKeyListNext = s_orderLists[orderKind].xFirst;
      s_orderLists[orderKind].xFirst = orderKeyNew;
    }
    else{
      orderKeyListNext = s_orders[orderKeyListAt].xLinks[LINK_LIST_NEXT];
      s_orders[orderKeyListAt].xLinks[LINK_LIST_NEXT] = orderKeyNew;
    }
    s_orders[orderKeyNew].xLinks[LINK_LIST_NEXT] = orderKeyListNext;
    s_orderLists[orderKind].length += 1;
  }
  function addOrder_toQueue(
    address orderKeyListAt,
    address orderKeyNew
  ) private {
    address orderKeyQueueLast = s_orders[orderKeyListAt].xLinks[LINK_QUEUE_LAST];
    if(orderKeyQueueLast == address(0)){
      s_orders[orderKeyListAt].xLinks[LINK_QUEUE_NEXT] = orderKeyNew;
    }
    else{
      s_orders[orderKeyQueueLast].xLinks[LINK_QUEUE_NEXT] = orderKeyNew;
    }
    s_orders[orderKeyListAt].xLinks[LINK_QUEUE_LAST] = orderKeyNew;
  }
  function removeOrderListFirst(
    uint8 orderKind
  ) private {
    address orderKeyListFirst = s_orderLists[orderKind].xFirst;
    if(orderKeyListFirst == address(0)){
      require(false,"[ERR] removeOrderListFirst");
    }
    address orderKeyQueueSecond = s_orders[orderKeyListFirst].xLinks[LINK_QUEUE_NEXT];
    if(orderKeyQueueSecond == address(0)){
      s_orderLists[orderKind].xFirst = s_orders[orderKeyListFirst].xLinks[LINK_LIST_NEXT];
      s_orders[orderKeyListFirst].xLinks[LINK_LIST_NEXT] = address(0);
      require(s_orderLists[orderKind].length >= 1,"[ERR2] removeOrderListFirst");
      s_orderLists[orderKind].length -= 1;
    }
    else{
      s_orderLists[orderKind].xFirst = orderKeyQueueSecond;
      s_orders[orderKeyQueueSecond].xLinks[LINK_LIST_NEXT] = s_orders[orderKeyListFirst].xLinks[LINK_LIST_NEXT];
      s_orders[orderKeyQueueSecond].xLinks[LINK_QUEUE_LAST] = s_orders[orderKeyListFirst].xLinks[LINK_QUEUE_LAST];
      s_orders[orderKeyListFirst].xLinks[LINK_LIST_NEXT] = address(0);
      s_orders[orderKeyListFirst].xLinks[LINK_QUEUE_NEXT] = address(0);
      s_orders[orderKeyListFirst].xLinks[LINK_QUEUE_LAST] = address(0);
    }
  }
  function getOrderListFirst(
    uint8 orderKind
  ) private view returns(address orderKeyListFirst) {
    orderKeyListFirst = s_orderLists[orderKind].xFirst;
    if(orderKeyListFirst == address(0)){
      require(false,"[ERR] getOrderListFirst");
    }
  }

  // Currency
  uint8 private CURRENCY_USD = 0;
  uint8 private CURRENCY_EUR = 1;
  struct Currency {
    mapping(address => uint32) balances;
  }
  mapping(uint8 => Currency) private s_currencies;
  function initCurrency() private {
    address xContract = address(this);
    uint32 amountMax = 1000000;
    s_currencies[CURRENCY_USD].balances[xContract] = amountMax;
    s_currencies[CURRENCY_EUR].balances[xContract] = amountMax;
  }
  function sendCurrency(
    uint8 currencyKind,
    address xFrom,
    address xTo,
    uint32 amount
  ) private {
    require(xFrom != address(0), "[ERR] sendCurrency");
    require(xTo != address(0), "[ERR2] sendCurrency");
    s_currencies[currencyKind].balances[xFrom] -= amount;
    s_currencies[currencyKind].balances[xTo] += amount;
  }
  function GetCurrencyBalance(address xSelf) public view returns(uint32 balance_USD,uint32 balance_EUR){
    balance_USD = s_currencies[CURRENCY_USD].balances[xSelf];
    balance_EUR = s_currencies[CURRENCY_EUR].balances[xSelf];
  }
  function CreateWalletCurrency() public {
    (uint32 balance_USD,uint32 balance_EUR) = GetCurrencyBalance(msg.sender);
    require((balance_USD == 0) && (balance_EUR == 0), "[ERR] Only once.");
    address xContract = address(this);
    uint32 amount = 1000;
    sendCurrency(CURRENCY_USD,xContract,msg.sender,amount);
    sendCurrency(CURRENCY_EUR,xContract,msg.sender,amount);
  }
  function depositCurrency(
    uint8 orderKind,
    address xTo,
    uint32 price10000,
    uint32 amount
  ) private {
    uint32 amountCurrency = getAmountCurrency(orderKind,price10000,amount);
    sendCurrency(orderKind,msg.sender,xTo,amountCurrency);
  }
  function transferCurrency(
    uint8 orderKind,
    address xFrom,
    address xTo,
    uint32 price10000,
    uint32 amount
  ) private {
    uint32 amountCurrency = getAmountCurrency(orderKind,price10000,amount);
    sendCurrency(orderKind,xFrom,xTo,amountCurrency);
  }
  function getAmountCurrency(
    uint8 orderKind,
    uint32 price10000,
    uint32 amount
  ) private view returns(uint32 amountCurrency) {
    if(orderKind == ORDER_SELL){
      amountCurrency = amount;
    }
    else if(orderKind == ORDER_BUY){
      amountCurrency = price10000 * amount;
    }
    else{
      require(false,"[ERR] getAmountCurrency");
    }
  }

  // Ehter fee
  function depositEtherFee(address xOwner,uint deposit) private {
    // Ether : the owner of owner >> this contract
    require(msg.sender == xOwner, "Only sender.");
    uint feeWeiMin = 100;
    require(deposit >= feeWeiMin, "More fee.");
    s_orders[xOwner].deposit = deposit;
  }
  function payReward(uint deposit) private {
    // Ether : this contract >> the worker to execute orders
    msg.sender.transfer(deposit);
  }

  // Trade
  constructor() public {
    initCurrency();
  }
  function SellOrder(uint32 price10000,uint32 amount) public payable {
    newOrder(ORDER_SELL,price10000,amount);
  }
  function BuyOrder(uint32 price10000,uint32 amount) public payable {
    newOrder(ORDER_BUY,price10000,amount);
  }
  function newOrder(
    uint8 orderKind,
    uint32 price10000,
    uint32 amount
  ) private {
    address xFrom = msg.sender;
    require(xFrom != address(0), "[ERR] newOrder");
    uint deposit = msg.value;
    require(price10000 > 0, "[ERR2] newOrder");
    require(amount > 0, "[ERR3] newOrder");
    address orderKey = createOrder(orderKind,price10000,amount,deposit);
    addOrderList(orderKind,orderKey);
    depositCurrency(orderKind,orderKey,price10000,amount);
    depositEtherFee(xFrom,deposit);
  }
  function DoAgreement() public returns(bool isDone) {
    address orderKeySell = getOrderListFirst(ORDER_SELL);
    address orderKeyBuy = getOrderListFirst(ORDER_BUY);
    uint32 price10000Sell = s_orders[orderKeySell].primaryKey;
    uint32 price10000Buy = s_orders[orderKeyBuy].primaryKey;
    if(price10000Sell > price10000Buy){
      isDone = false;
    }
    else{
      uint32 amountSell = s_orders[orderKeySell].amount;
      uint32 amountBuy = s_orders[orderKeyBuy].amount;
      uint32 amountDone = 0;
      uint depositSell = 0;
      uint depositBuy = 0;
      if(amountSell == amountBuy){
        removeOrderListFirst(ORDER_SELL);
        removeOrderListFirst(ORDER_BUY);
        s_orders[orderKeySell].amount = 0;
        s_orders[orderKeyBuy].amount = 0;
        amountDone = amountSell;
        depositSell = s_orders[orderKeySell].deposit;
        depositBuy = s_orders[orderKeyBuy].deposit;
        s_orders[orderKeySell].deposit = 0;
        s_orders[orderKeyBuy].deposit = 0;
      }
      else if(amountSell > amountBuy){
        removeOrderListFirst(ORDER_BUY);
        uint32 amountRemain = amountSell - amountBuy;
        s_orders[orderKeySell].amount = amountRemain;
        amountDone = amountBuy;
        depositSell = s_orders[orderKeySell].deposit * uint(amountDone) / uint(amountSell);
        s_orders[orderKeySell].deposit -= depositSell;
        depositBuy = s_orders[orderKeyBuy].deposit;
        s_orders[orderKeyBuy].deposit = 0;
      }
      else if(amountSell < amountBuy){
        removeOrderListFirst(ORDER_SELL);
        uint32 amountRemain = amountBuy - amountSell;
        s_orders[orderKeyBuy].amount = amountRemain;
        amountDone = amountSell;
        depositSell = s_orders[orderKeySell].deposit;
        s_orders[orderKeySell].deposit = 0;
        depositBuy = s_orders[orderKeyBuy].deposit * uint(amountDone) / uint(amountBuy);
        s_orders[orderKeyBuy].deposit -= depositBuy;
      }
      swapOrderCurrency(
        orderKeySell,
        orderKeyBuy,
        price10000Sell,
        price10000Buy,
        amountSell,
        amountBuy
      );
      payReward(depositSell + depositBuy);
      s_agreeInfoList.push(AgreeInfo({
        orderKeySell: orderKeySell,
        orderKeyBuy: orderKeyBuy,
        priceSell: price10000Sell,
        priceBuy: price10000Buy,
        amountDone: amountDone,
        timeStamp: now
      }));
      isDone = true;
    }
  }
  function swapOrderCurrency(
    address orderKeySell,
    address orderKeyBuy,
    uint32 price10000Sell,
    uint32 price10000Buy,
    uint32 amountSell,
    uint32 amountBuy
  ) private {
    address xOwnerSell = s_orders[orderKeySell].xOwner;
    address xOwnerBuy = s_orders[orderKeyBuy].xOwner;
    transferCurrency(ORDER_SELL,orderKeySell,xOwnerBuy,price10000Sell,amountSell);
    transferCurrency(ORDER_BUY,orderKeyBuy,xOwnerSell,price10000Buy,amountBuy);
  }
  struct AgreeInfo{
    address orderKeySell;
    address orderKeyBuy;
    uint32 priceSell;
    uint32 priceBuy;
    uint32 amountDone;
    uint timeStamp;
  }
  AgreeInfo[] public s_agreeInfoList;
  function GetOrder(address orderKey0) public view returns(
    uint8 orderKind,
    address orderKey,
    address xLink_LIST_NEXT,
    address xLink_QUEUE_NEXT,
    address xLink_QUEUE_LAST,
    address xOwner,
    uint32 price10000,
    uint32 amount,
    uint deposit,
    uint timeStamp
  ) {
    orderKind = s_orders[orderKey].orderKind;
    orderKey = orderKey0;
    xLink_LIST_NEXT = s_orders[orderKey].xLinks[LINK_LIST_NEXT];
    xLink_QUEUE_NEXT = s_orders[orderKey].xLinks[LINK_QUEUE_NEXT];
    xLink_QUEUE_LAST = s_orders[orderKey].xLinks[LINK_QUEUE_LAST];
    xOwner = s_orders[orderKey].xOwner;
    price10000 = s_orders[orderKey].primaryKey;
    amount = s_orders[orderKey].amount;
    deposit = s_orders[orderKey].deposit;
    timeStamp = s_orders[orderKey].timeStamp;
  }
  function GetAgreeInfoLen() public view returns(uint agreeInfoListLen) {
    agreeInfoListLen = s_agreeInfoList.length;
  }
}
