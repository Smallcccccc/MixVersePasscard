//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


contract MIXToken is Ownable, ERC20 {

    uint256 private constant preMineSupply = 0;     //初始数量
    uint256 private constant maxSupply = 10 * 1e7;  //最大发行数量

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _minters;

    //创建token并添加初始数量
    constructor() ERC20("MixVerse Token", "MIX"){
        _mint(_msgSender(), preMineSupply);
    }

    //外部调用铸币方法
    function mint(address _to, uint256 _amount) external onlyMinter returns (bool) {
        require(_amount.add(totalSupply()) <= maxSupply);
        _mint(_to, _amount);
        return true;
    }

    //增加铸币工人
    function addMinter(address _addMinter) public onlyOwner returns (bool) {
        require(_addMinter != address(0), "MIXToken:  _addMinter is the zero address");
        return EnumerableSet.add(_minters, _addMinter);
    }

    //删除某个铸币工人
    function delMinter(address _delMinter) public onlyOwner returns (bool) {
        require(_delMinter != address(0), "MIXToken:  _delMinter is the zero address");
        return EnumerableSet.remove(_minters, _delMinter);
    }

    //获取某个铸币工人地址
    function getMinter(uint256 _index) public view onlyOwner returns (address) {
        require(_index <= getMinterLength() - 1, "MIXToken: index out of bounds");
        return EnumerableSet.at(_minters, _index);
    }

    //获取铸币工人个数
    function getMinterLength() public view returns (uint256) {
        return EnumerableSet.length(_minters);
    }

    //修饰符，操作者是否是铸币工人
    modifier onlyMinter(){
        require(isMinter(_msgSender()), "caller is not the minter");
        _;
    }

    //是否是铸币工人
    function isMinter(address account) public view returns (bool) {
        return _minters.contains(account);
    }
    
}
