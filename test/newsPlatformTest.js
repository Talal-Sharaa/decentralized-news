const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NewsPlatform", function () {
  let NewsPlatform, newsPlatform, owner, addr1, addr2;
  beforeEach(async function () {
    NewsPlatform = await ethers.getContractFactory("NewsPlatform");
    [owner, addr1, addr2] = await ethers.getSigners();
    newsPlatform = await NewsPlatform.deploy();
  });
  describe("registerPublisher", function () {
    it("Should register a new publisher", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      const publisher = await newsPlatform.publishers(addr1.address);
      expect(publisher.isRegistered).to.equal(true);
    });

    it("Should fail if the publisher is already registered", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await expect(
        newsPlatform.connect(owner).registerPublisher(addr1.address)
      ).to.be.revertedWith("Publisher already registered");
    });
  });

  describe("submitArticle", function () {
    it("Should submit a new article", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await newsPlatform
        .connect(addr1)
        .submitArticle("Test Title", "Test Content");
      const article = await newsPlatform.articles(1);
      expect(article.title).to.equal("Test Title");
      expect(article.content).to.equal("Test Content");
    });

    it("Should fail if the sender is not a publisher", async function () {
      await expect(
        newsPlatform.connect(addr1).submitArticle("Test Title", "Test Content")
      ).to.be.revertedWith("Caller is not a publisher");
    });

    it("Should fail if the title is empty", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await expect(
        newsPlatform.connect(addr1).submitArticle("", "Test Content")
      ).to.be.revertedWith("Title cannot be empty");
    });

    it("Should fail if the content is empty", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await expect(
        newsPlatform.connect(addr1).submitArticle("Test Title", "")
      ).to.be.revertedWith("Content cannot be empty");
    });
  });

  describe("updateArticle", function () {
    it("Should update an article", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await newsPlatform
        .connect(addr1)
        .submitArticle("Test Title", "Test Content");
      await newsPlatform
        .connect(addr1)
        .updateArticle(1, "Updated Title", "Updated Content");
      const article = await newsPlatform.articles(1);
      expect(article.title).to.equal("Updated Title");
      expect(article.content).to.equal("Updated Content");
    });

    it("Should fail if the article does not exist", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await expect(
        newsPlatform
          .connect(addr1)
          .updateArticle(1, "Updated Title", "Updated Content")
      ).to.be.revertedWith("Article does not exist");
    });

    it("Should fail if the sender is not the original publisher", async function () {
      // Register two publishers
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await newsPlatform.connect(owner).registerPublisher(addr2.address);

      // Submit an article with the first publisher
      await newsPlatform
        .connect(addr1)
        .submitArticle("Test Title", "Test Content");

      // Try to update the article with the second publisher
      await expect(
        newsPlatform
          .connect(addr2)
          .updateArticle(1, "Updated Title", "Updated Content")
      ).to.be.revertedWith("Only the original publisher can update.");
    });
    it("Should fail if the new title is empty", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await newsPlatform
        .connect(addr1)
        .submitArticle("Test Title", "Test Content");
      await expect(
        newsPlatform.connect(addr1).updateArticle(1, "", "Updated Content")
      ).to.be.revertedWith("New title cannot be empty");
    });

    it("Should fail if the new content is empty", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await newsPlatform
        .connect(addr1)
        .submitArticle("Test Title", "Test Content");
      await expect(
        newsPlatform.connect(addr1).updateArticle(1, "Updated Title", "")
      ).to.be.revertedWith("New content cannot be empty");
    });
  });
  describe("getArticle", function () {
    it("Should return the correct article", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await newsPlatform
        .connect(addr1)
        .submitArticle("Test Title", "Test Content");
      const article = await newsPlatform.getArticle(1);
      expect(article.title).to.equal("Test Title");
      expect(article.content).to.equal("Test Content");
    });

    it("Should fail if the article does not exist", async function () {
      await expect(newsPlatform.getArticle(1)).to.be.revertedWith(
        "Article does not exist"
      );
    });
  });

  describe("getArticlesByPublisher", function () {
    it("Should return all articles by a publisher", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await newsPlatform
        .connect(addr1)
        .submitArticle("Test Title", "Test Content");
      const articles = await newsPlatform.getArticlesByPublisher(addr1.address);
      expect(articles[0].title).to.equal("Test Title");
      expect(articles[0].content).to.equal("Test Content");
    });

    it("Should fail if the publisher is not registered", async function () {
      await expect(
        newsPlatform.getArticlesByPublisher(addr1.address)
      ).to.be.revertedWith("Publisher not registered");
    });
  });
  describe("getAllPublishers", function () {
    it("Should return all registered publishers", async function () {
      await newsPlatform.connect(owner).registerPublisher(addr1.address);
      await newsPlatform.connect(owner).registerPublisher(addr2.address);

      const publishers = await newsPlatform.getAllPublishers();

      expect(publishers.length).to.equal(2);
      expect(publishers[0].publisherID).to.equal(addr1.address);
      expect(publishers[1].publisherID).to.equal(addr2.address);
    });
  });
});
