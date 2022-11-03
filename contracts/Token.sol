// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

contract Token {
    string public name = "UnpredictableDAO Governance Token";
    string public symbol = "UGT";
    uint8 public decimals = 8;
    uint256 public totalSupply = 100000000 * 10 ** decimals;

    mapping(address => uint256) public balances;

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }


    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);

        return true;
    }


    mapping (address => mapping (address => uint256)) private allowed;

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);

        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    constructor(address _mintAddress) {
        balances[_mintAddress] = totalSupply;
    }
}
