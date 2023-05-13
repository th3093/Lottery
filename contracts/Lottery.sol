// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.9.0;

contract lottery{

    address public admin;
    address payable[] public participants;

    constructor(){
        admin=msg.sender;
    }

    modifier isManager(){
        require(msg.sender == admin);
        _;
    }

    modifier isNotManager(){
        require(msg.sender != admin);
        _;
    }

    modifier enoughParticipants(){
        require(participants.length>=3);
        _;
    }

    event Winner(address _winner, uint value, uint winningNr, uint nrParticipants);

    receive() external payable isNotManager() {
        require(msg.value==0.01 ether);
        participants.push(payable(msg.sender));
    }

    function getBalance() public view isManager() returns(uint){
        return address(this).balance;
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, participants.length)));
    }

    function winner() public isManager() enoughParticipants(){
        address payable _winner;
        uint r = random();
        uint index = r % participants.length;
        _winner = participants[index];
        emit Winner(_winner, getBalance(), index, participants.length);
        _winner.transfer(getBalance());
        delete participants;
    }
}