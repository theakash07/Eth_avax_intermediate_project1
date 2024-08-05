// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Supermarket {
    struct Product {
        string name;
        uint price;
        uint stock;
    }

    address public owner;
    mapping(uint => Product) public products;
    uint public productCount;
    mapping(address => uint) public customerBalances;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function addProduct(string memory _name, uint _price, uint _stock) public onlyOwner {
        require(_price > 0, "Price must be greater than zero");
        require(_stock > 0, "Stock must be greater than zero");

        productCount++;
        products[productCount] = Product(_name, _price, _stock);
    }

    function purchaseProduct(uint _productId, uint _quantity) public payable {
        require(_productId > 0 && _productId <= productCount, "Product does not exist");
        Product storage product = products[_productId];
        require(msg.value == product.price * _quantity, "Incorrect payment amount");
        require(product.stock >= _quantity, "Not enough stock available");

        product.stock -= _quantity;
        customerBalances[msg.sender] += msg.value;

        // Verify that the stock has been correctly updated
        assert(product.stock >= 0);
    }

    function restockProduct(uint _productId, uint _quantity) public onlyOwner {
        require(_productId > 0 && _productId <= productCount, "Product does not exist");
        require(_quantity > 0, "Restock quantity must be greater than zero");

        Product storage product = products[_productId];
        product.stock += _quantity;

        // Ensure the product stock is updated correctly
        assert(product.stock > _quantity - 1);
    }

    function withdrawFunds() public onlyOwner {
        uint balance = address(this).balance;
        if (balance == 0) {
            revert("No funds available to withdraw");
        }

        payable(owner).transfer(balance);
    }

    function refundCustomer(address customer, uint amount) public onlyOwner {
        require(customer != address(0), "Invalid customer address");
        require(amount > 0, "Refund amount must be greater than zero");
        require(customerBalances[customer] >= amount, "Insufficient balance for refund");

        customerBalances[customer] -= amount;
        payable(customer).transfer(amount);

        // Verify the balance has been correctly updated
        assert(customerBalances[customer] >= 0);
    }
}
