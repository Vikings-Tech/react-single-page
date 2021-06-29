import {useState,useEffect} from "react";
import Web3 from "web3";
import abi from "./abi.json";

let web3,contract;
function App() {

  const [account,setAccount] = useState()

  useEffect(async()=>{
    if(!window.ethereum){
      console.log("Get metamask plis request");
      return;
    }
    await window.ethereum.request({method:'eth_requestAccounts'});
    web3 = new Web3(window.ethereum);
    setAccount(window.ethereum.selectedAddress);
    console.log(web3.eth.getChainId);
    const contractAddress = "0xf9C40426513965AF10B722CE65e60D214966643A";
    contract = new web3.eth.Contract(abi,contractAddress);
    
  },[]);

  contract.events.PayoutFulfilled()
  .on('data', (event) => {
	console.log(event);
  })
  .on('error', console.error);

  async function Gamble(){
    const amount = web3.utils.toWei("0.05","ether");
    const result = contract.methods.gamble().send({from: account, value:amount});
    result.on("transactionHash",(hash)=>{
      console.log("Transaction sent successfully. Check console for Transaction hash")
      console.log("Transaction Hash is ",hash)
    }).once("confirmation",(confirmationNumber,receipt)=>{
      if(receipt.status){
        console.log("Transaction processed successfully")
      }else{
        console.log("Transaction failed");
      }
      console.log(receipt)
    })
  }


  return (
    <div className="App">
      <button type="button" className="button" onClick={Gamble}>Submit</button>
    </div >
  );
}

export default App;