import {useState,useEffect} from "react";
import Web3 from "web3";

let web3;
function App() {

  

  useEffect(async()=>{
    if(!window.ethereum){
      console.log("Get metamask plis request");
      return;
    }
    await window.ethereum.request({method:'eth_requestAccounts'});
    web3 = new Web3(window.ethereum);
    
    
  },[]);

  async function Gamble(){

  }


  return (
    <div className="App">
      <button type="button" className="button" onClick={Gamble}>Submit</button>
    </div >
  );
}

export default App;