// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BookSwap {
    struct Book {
        uint256 id;
        string title;
        string author;
        string condition;
        address owner;
        bool isAvailable;
        uint256 depositAmount;
    }

    mapping(uint256 => Book) public books;
    uint256 public bookCount;
    mapping(address => uint256[]) public userBooks;
    mapping(uint256 => address[]) public bookHistory;

    event BookListed(uint256 indexed bookId, string title, address owner);
    event BookSwapped(uint256 indexed bookId, address from, address to);
    event BookRemoved(uint256 indexed bookId);

    constructor() {
        bookCount = 0;
    }

    function listBook(
        string memory _title,
        string memory _author,
        string memory _condition,
        uint256 _depositAmount
    ) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_author).length > 0, "Author cannot be empty");
        require(_depositAmount > 0, "Deposit amount must be greater than 0");

        bookCount++;
        books[bookCount] = Book(
            bookCount,
            _title,
            _author,
            _condition,
            msg.sender,
            true,
            _depositAmount
        );

        userBooks[msg.sender].push(bookCount);
        bookHistory[bookCount].push(msg.sender);

        emit BookListed(bookCount, _title, msg.sender);
    }

    function initiateSwap(uint256 _bookId) public payable {
        require(_bookId <= bookCount && _bookId > 0, "Invalid book ID");
        Book storage book = books[_bookId];
        require(book.isAvailable, "Book is not available");
        require(book.owner != msg.sender, "Cannot swap with yourself");
        require(msg.value == book.depositAmount, "Incorrect deposit amount");

        book.isAvailable = false;
        address previousOwner = book.owner;
        book.owner = msg.sender;
        bookHistory[_bookId].push(msg.sender);

        payable(previousOwner).transfer(msg.value);

        emit BookSwapped(_bookId, previousOwner, msg.sender);
    }

    function removeBook(uint256 _bookId) public {
        require(_bookId <= bookCount && _bookId > 0, "Invalid book ID");
        Book storage book = books[_bookId];
        require(book.owner == msg.sender, "Not the book owner");
        require(book.isAvailable, "Book is not available");

        delete books[_bookId];
        emit BookRemoved(_bookId);
    }

    function getBooksByUser(address _user) public view returns (uint256[] memory) {
        return userBooks[_user];
    }

    function getBookHistory(uint256 _bookId) public view returns (address[] memory) {
        return bookHistory[_bookId];
    }
}