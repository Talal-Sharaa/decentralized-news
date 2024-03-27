//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract NewsPlatform is AccessControl {
    bytes32 public constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PUBLISHER_ROLE, msg.sender);
    }

    modifier onlyPublisher() {
        require(hasRole(PUBLISHER_ROLE, msg.sender), "Caller is not a publisher");
        _;
    }
    // ... other structs and variables ...
 struct Publisher {
        address publisherID;
        uint256 registrationTimestamp;
        int256 reputationScore;
        bool isRegistered;
    }

    struct Reader {
        address readerID;
    }

    mapping(uint256 => Article) public articles;
    mapping(uint256 => ArticlewithOutVersion) public articleVersionless;
    mapping(address => Publisher) public publishers;
    mapping(address => uint256[]) public publisherArticles; // Maps a publisher address to an array of their article IDs

    mapping(address => Reader) public readers;
    uint256 private articleIdCounter;

    struct ArticleVersion {
        uint256 versionNumber;
        string articleHash;
        address editorID;
        uint256 editTimestamp; 
    }

    struct Article {
        string title;
        string content;
        uint256 timestamp;
        address publisherID;
        string articleHash;
        mapping(uint256 => ArticleVersion) versionHistory; 
    }
        struct ArticlewithOutVersion {
        string title;
        string content;
        uint256 timestamp;
        address publisherID;
        string articleHash;
    }

    // ... other functions ...
  function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        return string(abi.encodePacked(_bytes32));
    }

    function registerPublisher(address publisherAddress) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        require(!publishers[publisherAddress].isRegistered, "Publisher already registered");

        publishers[publisherAddress] = Publisher({
            publisherID: publisherAddress,
            registrationTimestamp: block.timestamp,
            reputationScore: 0,
            isRegistered: true
        });

        grantRole(PUBLISHER_ROLE, publisherAddress);
    }
    
    // Add this state variable to your contract
    mapping(uint256 => uint256) public articleVersionCounts;

    function submitArticle(string memory title, string memory content) public onlyPublisher {
    require(bytes(title).length > 0, "Title cannot be empty");
    require(bytes(content).length > 0, "Content cannot be empty");

    articleIdCounter++;
    uint256 articleId = articleIdCounter;

    bytes32 articleHash = keccak256(abi.encodePacked(title, content));

    articles[articleId].title = title;
    articles[articleId].content = content;
    articles[articleId].timestamp = block.timestamp;
    articles[articleId].publisherID = msg.sender;
    articles[articleId].articleHash = bytes32ToString(articleHash);

    uint256 initialVersion = 1;
    articles[articleId].versionHistory[initialVersion] = ArticleVersion({
        versionNumber: initialVersion,
        articleHash: bytes32ToString(articleHash),
        editorID: msg.sender,
        editTimestamp: block.timestamp
    });

    publisherArticles[msg.sender].push(articleId);

    // Add the article to the versionless mapping
    articleVersionless[articleId] = ArticlewithOutVersion({
        title: title,
        content: content,
        timestamp: block.timestamp,
        publisherID: msg.sender,
        articleHash: bytes32ToString(articleHash)
    });
}


    function updateArticle(uint256 articleId, string memory newTitle, string memory newContent) public onlyPublisher {
            address originalPublisher = articles[articleId].publisherID;
        require(articles[articleId].timestamp != 0, "Article does not exist");
    require(msg.sender == originalPublisher, "Only the original publisher can update.");
        require(bytes(newTitle).length > 0, "New title cannot be empty");
        require(bytes(newContent).length > 0, "New content cannot be empty");

        bytes32 newArticleHash = keccak256(abi.encodePacked(newTitle, newContent));

        // Update primary article fields (consider if you want to preserve older versions of these)
        articles[articleId].title = newTitle;
        articles[articleId].content = newContent;
        articles[articleId].articleHash = bytes32ToString(newArticleHash);

        // Add a new version
        uint256 newVersionNumber = articleVersionCounts[articleId] + 1;
        articles[articleId].versionHistory[newVersionNumber] = ArticleVersion({
            versionNumber: newVersionNumber,
            articleHash: bytes32ToString(newArticleHash),
            editorID: msg.sender,
            editTimestamp: block.timestamp
        });

        // Update the version count for the article
        articleVersionCounts[articleId] = newVersionNumber;
    }

function getArticleHistory(uint256 articleId) public view returns (ArticleVersion[] memory) {
    require(articles[articleId].timestamp != 0, "Article does not exist");

    uint256 numberOfVersions = articleVersionCounts[articleId];
    ArticleVersion[] memory history = new ArticleVersion[](numberOfVersions); 

    for (uint256 i = 1; i <= numberOfVersions; i++) { // Start from version 1
        history[i - 1] = articles[articleId].versionHistory[i]; 
    }

    return history;
}
 function getArticle(uint256 articleId) public view returns (ArticlewithOutVersion memory) {
        require(articleVersionless[articleId].timestamp != 0, "Article does not exist");
        return articleVersionless[articleId];
    }

    function getArticlesByPublisher(address publisherAddress) public view returns (ArticlewithOutVersion[] memory) {
        require(publishers[publisherAddress].isRegistered, "Publisher not registered");

        uint256[] memory articleIds = publisherArticles[publisherAddress];
        ArticlewithOutVersion[] memory articlesByPublisher = new ArticlewithOutVersion[](articleIds.length); 

        for (uint256 i = 0; i < articleIds.length; i++) {
            require(articles[articleIds[i]].timestamp != 0, "Article does not exist");
            articlesByPublisher[i] = articleVersionless[articleIds[i]]; 
        }

        return articlesByPublisher;
    }
}
