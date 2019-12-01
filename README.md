# [dapp_trade](https://github.com/zombietimes/dapp_trade)
This is a sample application of DApps.  

## Overview
[dapp_trade](https://github.com/zombietimes/dapp_trade) allows simulating market transactions on the blockchain.  
It is created as a project of Truffle framework.  
It allows accessing to Ganache(Ethereum) and Loom Network.  
It allows accessing through Express server(application server).  
- [DApps : Medium](https://medium.com/swlh/understanding-dapps-decentralized-applications-8f3668ebdc9a)  
- [Truffle : Official](https://truffleframework.com/)  
- [Ganache : Official](https://truffleframework.com/docs/ganache/overview)  
- [Loom Network SDK : Official](https://loomx.io/developers/)  
- [Express : Official](https://expressjs.com/)  
- [Metamask : Official](https://metamask.io/)  

At first select ganche1 address.  
![dapp_trade_0000](https://user-images.githubusercontent.com/50263232/69911443-e8985480-145e-11ea-9cb6-9b71271a5a6a.png)  
  
Create a fake currency wallet.  
![dapp_trade_0001](https://user-images.githubusercontent.com/50263232/69911447-f8b03400-145e-11ea-8b44-6dfef048a2e6.png)  
![dapp_trade_0002](https://user-images.githubusercontent.com/50263232/69911452-08c81380-145f-11ea-8ca6-1cffe5388977.png)  
  
Sell and buy orders.  
If you are an investor,  
you have to deposit the Ether fee for someone to execute your orders.  
![dapp_trade_0003](https://user-images.githubusercontent.com/50263232/69911455-18475c80-145f-11ea-9772-de91039310ee.png)  
![dapp_trade_0004](https://user-images.githubusercontent.com/50263232/69911464-31e8a400-145f-11ea-9fae-e821f1073fc9.png)  
![dapp_trade_0005](https://user-images.githubusercontent.com/50263232/69911468-3e6cfc80-145f-11ea-9d75-9f678ea44547.png)  
  
Executing order.  
If you are an executor,  
you can get reward the Ether fee for your work to execute orders.  
![dapp_trade_0006](https://user-images.githubusercontent.com/50263232/69911473-517fcc80-145f-11ea-8f23-e32b266d1a46.png)  
![dapp_trade_0007](https://user-images.githubusercontent.com/50263232/69911478-60667f00-145f-11ea-80d3-4b3764d7f33e.png)  
![dapp_trade_0008](https://user-images.githubusercontent.com/50263232/69911482-6a887d80-145f-11ea-8f07-d657b98952d9.png)  

## Description
Let's run and analyze the sample DApps.  
You can understand deeply by editing the sample code.  
I think that it is worth learning the smart contract development.  
I focus on Ethereum and Loom Network as the DApps.  

### Sample DApps
I created some sample smart contracts below.  
I hope to be useful to you when you develop DApps.  
- [Hello world : HelloZombies.sol](https://github.com/zombietimes/dapp_helloWorld)
- [ERC20 : Coin20.sol](https://github.com/zombietimes/dapp_erc20)
- [ERC721 : Asset721.sol](https://github.com/zombietimes/dapp_erc721)
- [Multi contract : ImportZombies.sol](https://github.com/zombietimes/dapp_multiContract)
- [Sending Ether](https://github.com/zombietimes/dapp_sendEther)
- [Market simulattion : Trade.sol](https://github.com/zombietimes/dapp_trade) : Here!

### Setting up the development environment.
The script file [setup0000_all](https://github.com/zombietimes/setup0000_all) is useful to set up the development environment.  
It consists of the external script files below.  
- [setup0000_all](https://github.com/zombietimes/setup0000_all)  

### Environment
This script file is for Ubuntu(Linux).  
I recommend that you use VirtualBox + Ubuntu.  

## Explanation
I explain the source code of [dapp_trade](https://github.com/zombietimes/dapp_trade).  
It is not enough to debug it, but ...  

### The linked list with the contract address.
The trading order data should be able to add, remove and sort.  
The queue and the sorted list is very convenient as the data container.  
So, I try to use the linked list on the blockchain.  
  
The linked list written by solidity?  
  
A self-reference struct is not supported in solidity.  
How is each data linked and unlinked?  
  
My idea is to use the new contract address as the pointer of each data.  
Each data has the different contract address.  
The data links to others by using the contract address of it.  
```sol
# Solidity : example
contract ItemKey {}
contract Trade {
  struct Order {
    address orderKeyNext;  // for ordekey of next data
    uint32 price;
    uint32 amount;
  }
  mapping(address => Order) public s_orders;
  :
  function Test() public {
    address orderKey1 = createOrder(100,3);
    address orderKey2 = createOrder(110,4);
    s_orders[orderKey1].orderKeyNext = orderKey2;
  }
  function createOrder(
    uint32 price,
    uint32 amount
  ) private returns(address orderKey) {
    orderKey = newOrderKey();
    s_orders[orderKey] = Order({
      price: price,
      amount: amount
    });
  }
  function newOrderKey() private returns(address orderKey) {
    ItemKey itemKey = new ItemKey();  // create new instance
    orderKey = address(itemKey);
  }
  :
}
```
Isn't it an excellent idea???  

### Expensive fee in gas
The linked list with the contract address consumes a lot of gas.  
  
Who uses so expensive Dapps?  
I want not to use it at least!? .^0^.  
  
I suggest the economic system to treat with the expensive fee.  
The investor pays the reward for the worker who contributes to executing orders.  
```sol
# Solidity : example
contract Trade {
  :
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
  :
}
```
hmm...  
Does the idea work proper?  

### Easy nested list
The sell/buy order list has a sorted list.  
The list should sort by the price of the order.  
And there are some orders in which the price is the same.  
  
The orders are in a queue.  
The queue is in the sorted list.  
  
If components and containers in solidity are defined,  
it can cause out of the gas.  
  
How about the idea below?  
  
Each order data has two links.  
A link to the next data in the sorted list,  
and a link to the next data in the queue.  
```sol
# Solidity : example
contract Trade {
  struct Order {
    address link_list_Next;   // the link in the order list
    address link_queue_Next;  // the link in the order queue
    uint32 price;
    uint32 amount;
  }
  mapping(address => Order) public s_orders;
  :
}
```
In this way, there are no containers.  
Because there are only links, gas is smaller.  
I love myself!?  

## Usage
After setting up the development environment by [setup0000_all](https://github.com/zombietimes/setup0000_all),  
run `ubuntuCmd_setupDapp_trade.sh` on Ubuntu console window.  
You can compile and deploy the sample contract by Truffle framwork.  
And then, you can access it on the blockchain  
through Express server from the browser.  

### Compile and deploy to Ganache
At first, we have to compile and deploy the smart contract.  
The role of `ubuntuCmd_setupDapp_trade.sh` is below.  
- Copy the smart contract to Truffle project.
- Compile and deploy by using Truffle commands.
- Run Truffle console to Ganache(Ethereum private test network).
- Create Express project to run the smart contract through web server.
```sh
# Ubuntu commands.
git clone https://github.com/zombietimes/dapp_trade.git
cd dapp_trade
sh ./ubuntuCmd_setupDapp_trade.sh
```
![dapp_trade_0010](https://user-images.githubusercontent.com/50263232/69911486-7ffda780-145f-11ea-884c-8fd93ec9ede1.png)  

### Browser and Ethereum wallet on Ganache
The next step is about browser.  
In [dapp_trade](https://github.com/zombietimes/dapp_trade), you have to send Ether to order and can receive Ether for reward to execute orders.  
It is necessary to use Ether wallet Metamask.  
Metamask allows you to access the dapps on the blockchain such as Ganahche.  
![dapp_trade_0011](https://user-images.githubusercontent.com/50263232/69911492-8c820000-145f-11ea-94e4-5ab1580c6844.png)  
![dapp_trade_0012](https://user-images.githubusercontent.com/50263232/69911495-9a378580-145f-11ea-8536-c1bfcdc5aff5.png)  

### Webserver
The final step is running the webserver.  
Run the express project.  

```sh
# Ubuntu commands.
cd ~/dapps/web/by_express/trade
node ./bin/www
```
```sh
# Browser.
http://127.0.0.1:3000
```
![dapp_trade_0013](https://user-images.githubusercontent.com/50263232/69911500-a885a180-145f-11ea-842d-a6618964a074.png)  
![dapp_trade_0014](https://user-images.githubusercontent.com/50263232/69911501-b3d8cd00-145f-11ea-8dc2-6bbffecead76.png)  

If it failed, show [troubleShoot](https://github.com/zombietimes/troubleShoot).  

## Requirement
I confirmed that it works on Ubuntu Desktop 18.04 in VirtualBox.  
It works on the environment below.  
- On Ubuntu.
- Google Chrome.
- [setup0000_all](https://github.com/zombietimes/setup0000_all)

## Relative link
### Overview
- [Ethereum : Official](https://www.ethereum.org/)
- [Ethereum : Wikipedia](https://en.wikipedia.org/wiki/Ethereum)
- [Loom Network : Official](https://loomx.io/)
- [Loom Network : Binance wiki](https://info.binance.com/en/currencies/loom-network)

### Development
- [Online editor : EthFiddle](https://ethfiddle.com/)
- [Online editor : Remix](https://remix.ethereum.org/)

### Learning
- [Online learning : CryptoZombies](https://cryptozombies.io/)
- [Grammar : Solidity](https://solidity.readthedocs.io/)
- [Grammar : Best Practices](https://github.com/ConsenSys/smart-contract-best-practices)

### DApps
- [DApps : CryptoKitties](https://www.cryptokitties.co/)
- [DApps : Zombie Battle ground](https://loom.games/en/)

## Messages
Do you believe that the decentralized world is coming?  
Do you want to use [DApps](https://en.wikipedia.org/wiki/Decentralized_application)?  
Why?  

## License
BSD 3-Clause, see `LICENSE` file for details.  

