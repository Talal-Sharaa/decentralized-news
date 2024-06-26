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
    address[] public publisherAddresses;
    struct Reader {
        address readerID;
    }
    mapping(address => string) public publisherNames;
    mapping(uint256 => Article) public articles;
    mapping(uint256 => ArticlewithOutVersion) public articleVersionless;
    mapping(address => Publisher) public publishers;
    mapping(address => uint256[]) public publisherArticles; // Maps a publisher address to an array of their article IDs
mapping(string => address) public nameToPublisherAddress;
    mapping(address => Reader) public readers;
    uint256 private articleIdCounter;

    struct ArticleVersion {
        uint256 versionNumber;
        string articleHash;
        address editorID;
        uint256 editTimestamp; 
            string title; // Add this field
    string content; // And this field
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
            uint256 id;
        string title;
        string content;
        uint256 timestamp;
        address publisherID;
        string articleHash;
    }
    struct ArticleWithID {
    uint256 id;
    string title;
    string content;
    uint256 timestamp;
    address publisherID;
    string articleHash;
}

    
    function isAdmin(address user) public view returns (bool) {
    return hasRole(DEFAULT_ADMIN_ROLE, user);
}
    function isPublisher(address user) public view returns (bool) {
    return hasRole(PUBLISHER_ROLE, user);
}
    
function getAllPublishers() public view returns (Publisher[] memory) {
    uint256 totalPublishers = 0;

    // Count total registered publishers
    for (uint i = 0; i < publisherAddresses.length; i++) {
        address publisherAddr = publisherAddresses[i];
        if (publishers[publisherAddr].isRegistered) {
            totalPublishers++;
        }
    } 

    // Create an array to store publishers
    Publisher[] memory allPublishers = new Publisher[](totalPublishers);

    // Add registered publishers to the array
    uint256 index = 0;
    for (uint i = 0; i < publisherAddresses.length; i++) {
        address publisherAddr = publisherAddresses[i];
        if (publishers[publisherAddr].isRegistered) {
            allPublishers[index] = publishers[publisherAddr];
            index++;
        }
    }

    return allPublishers;
}
function getAllArticleIds() public view returns (uint256[] memory) {
    uint256 totalArticles = articleIdCounter;
    uint256[] memory allArticleIds = new uint256[](totalArticles);

    for (uint256 i = 1; i <= totalArticles; i++) {
        allArticleIds[i - 1] = i;
    }

    return allArticleIds;
}
    // ... other functions ...
    function grantAdminRole(address newAdmin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
    }
  function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        return string(abi.encodePacked(_bytes32));
    }

    function registerPublisher(address publisherAddress, string memory name) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
        require(!publishers[publisherAddress].isRegistered, "Publisher already registered");
       publishers[publisherAddress] = Publisher({
        publisherID: publisherAddress,
        registrationTimestamp: block.timestamp,
        reputationScore: 0,
        isRegistered: true
    });
    // Add the new publisher's address to publisherAddresses
    publisherAddresses.push(publisherAddress);
    publisherNames[publisherAddress] = name; // Store the publisher's name
    nameToPublisherAddress[name] = publisherAddress; // Add this line

    grantRole(PUBLISHER_ROLE, publisherAddress);
}

function getArticlesByName(string memory name) public view returns (ArticlewithOutVersion[] memory) {
    address publisherAddress = nameToPublisherAddress[name];
    require(publisherAddress != address(0), "Publisher not found"); // Check if the name exists
    return getArticlesByPublisher(publisherAddress);
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
            editTimestamp: block.timestamp,
            title: title,
            content: content
        });

        // Increment the version count for the article
        articleVersionCounts[articleId] = initialVersion;

        publisherArticles[msg.sender].push(articleId);

        // Add the article to the versionless mapping
        articleVersionless[articleId] = ArticlewithOutVersion({
            id: articleId,
            title: title,
            content: content,
            timestamp: block.timestamp,
            publisherID: msg.sender,
            articleHash: bytes32ToString(articleHash)
        });
    }


    function updateArticle(uint256 articleId, string memory newTitle, string memory newContent) public {
        // Check if the article exists
        require(articles[articleId].timestamp != 0, "Article does not exist");

        // Check if the sender is the publisher of the article
        require(msg.sender == articles[articleId].publisherID, "Only the publisher can update the article");

        // Check if the new title and content are not empty
        require(bytes(newTitle).length > 0, "New title cannot be empty");
        require(bytes(newContent).length > 0, "New content cannot be empty");

        // Compute the hash of the new content
        bytes32 newArticleHash = keccak256(abi.encodePacked(newTitle, newContent));

        // Update the article
        articles[articleId].title = newTitle;
        articles[articleId].content = newContent;
        articles[articleId].articleHash = bytes32ToString(newArticleHash);

        // Add a new version
        uint256 newVersionNumber = articleVersionCounts[articleId] + 1;
        articles[articleId].versionHistory[newVersionNumber] = ArticleVersion({
            versionNumber: newVersionNumber,
            articleHash: bytes32ToString(newArticleHash),
            editorID: msg.sender,
            editTimestamp: block.timestamp,
            title: newTitle,
            content: newContent
        });

        // Update the version count for the article
        articleVersionCounts[articleId] = newVersionNumber;
    }
function getArticleHistory(uint256 articleId) public view returns (ArticleVersion[] memory) {
    // Check if the article exists
    require(articles[articleId].timestamp != 0, "Article does not exist");

    // Get the number of versions
    uint256 numberOfVersions = articleVersionCounts[articleId];

    // Create an array to store the versions
    ArticleVersion[] memory history = new ArticleVersion[](numberOfVersions);

    // Get the versions
      for (uint256 i = 1; i <= numberOfVersions; i++) { 
        history[i - 1] = articles[articleId].versionHistory[i];
    }


    // Return the versions
    return history;
}
function getArticle(uint256 articleId) public view returns (ArticleWithID memory) {
    require(articleVersionless[articleId].timestamp != 0, "Article does not exist");
    return ArticleWithID({
        id: articleId,
        title: articleVersionless[articleId].title,
        content: articleVersionless[articleId].content,
        timestamp: articleVersionless[articleId].timestamp,
        publisherID: articleVersionless[articleId].publisherID,
        articleHash: articleVersionless[articleId].articleHash
    });
}

function getArticlesByPublisher(address publisherAddress) public view returns (ArticlewithOutVersion[] memory) {
    require(publishers[publisherAddress].isRegistered, "Publisher not registered");

    uint256[] memory articleIds = publisherArticles[publisherAddress];
    ArticlewithOutVersion[] memory articlesByPublisher = new ArticlewithOutVersion[](articleIds.length); 

    for (uint256 i = 0; i < articleIds.length; i++) {
        require(articles[articleIds[i]].timestamp != 0, "Article does not exist");
        articlesByPublisher[i] = ArticlewithOutVersion({
            id: articleIds[i],
            title: articles[articleIds[i]].title,
            content: articles[articleIds[i]].content,
            timestamp: articles[articleIds[i]].timestamp,
            publisherID: articles[articleIds[i]].publisherID,
            articleHash: articles[articleIds[i]].articleHash
        });
    }

    return articlesByPublisher;
}
}
