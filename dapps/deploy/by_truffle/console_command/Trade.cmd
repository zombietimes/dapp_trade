/*@CONTRACT: Trade */
Trade.address
Trade.deployed().then(ret=>instance=ret)
web3.eth.getAccounts().then(ret=>accounts=ret)

instance.CreateWalletCurrency({from:accounts[0]}).then()
instance.CreateWalletCurrency({from:accounts[1]}).then()
instance.CreateWalletCurrency({from:accounts[2]}).then()

info = instance.GetCurrencyBalance(accounts[0]).then()
info = instance.GetCurrencyBalance(accounts[1]).then()
info = instance.GetCurrencyBalance(accounts[2]).then()

web3.eth.getBalance(accounts[0]).then()
web3.eth.getBalance(accounts[1]).then()
web3.eth.getBalance(accounts[2]).then()

fee = 240
instance.SellOrder(11,1,{from:accounts[1],value:fee}).then()
instance.SellOrder(10,1,{from:accounts[1],value:fee}).then()
instance.SellOrder(10,2,{from:accounts[1],value:fee}).then()
instance.BuyOrder(10,3,{from:accounts[2],value:fee}).then()
instance.BuyOrder(11,1,{from:accounts[2],value:fee}).then()

web3.eth.getBalance(accounts[0]).then()
web3.eth.getBalance(accounts[1]).then()
web3.eth.getBalance(accounts[2]).then()

info = instance.DoAgreement({from:accounts[0]}).then()
web3.eth.getBalance(accounts[0]).then()
web3.eth.getBalance(accounts[1]).then()
web3.eth.getBalance(accounts[2]).then()

ORDER_SELL = 0;
ORDER_BUY = 1;
info = instance.s_orderLists(ORDER_SELL).then()
info = instance.s_orderLists(ORDER_BUY).then()
info = instance.GetOrder('0x4c28F8Ca7Bb24CeB41126F8F6B76230B77D06Ea8').then()
info = instance.GetOrder('0x1C2f3775c4730C17F9503B36B6dFA2b306a348Ab').then()
info = instance.GetOrder('0x94b1C843eEc54E07433Cc98b2D7da527617d3aab').then()
info = instance.GetOrder('0x26f8dD12a9080f908aAb5557033E9C6Bc86AF228').then()
info = instance.GetOrder('0xF686D591fF2524aAcbf4d043a680716aC988a450').then()

agreeInfoListLen = instance.GetAgreeInfoLen().then()
info = instance.s_agreeInfoList(0).then()
info = instance.s_agreeInfoList(1).then()
info = instance.s_agreeInfoList(2).then()
info.logs[0].args

.exit

