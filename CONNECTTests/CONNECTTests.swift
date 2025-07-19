//
//  CONNECTTests.swift
//  CONNECTTests
//
//  Created by Luke on 19.07.25.
//

import Testing
@testable import CONNECT

struct CONNECTTests {

    @Test func testUserModelValidation() async throws {
        let user = User(
            username: "testuser",
            email: "test@example.com",
            displayName: "Test User"
        )
        
        #expect(user.username == "testuser")
        #expect(user.email == "test@example.com")
        #expect(user.displayName == "Test User")
        #expect(user.friends.isEmpty)
        #expect(user.momentsCount == 0)
    }
    
    @Test func testCommentDepthCalculation() async throws {
        let user = User(username: "testuser", email: "test@example.com", displayName: "Test User")
        let moment = Moment(content: "Test moment", author: user)
        
        let parentComment = Comment(content: "Parent comment", author: user, moment: moment)
        let childComment = Comment(content: "Child comment", author: user, moment: moment, parentComment: parentComment)
        let grandchildComment = Comment(content: "Grandchild comment", author: user, moment: moment, parentComment: childComment)
        
        #expect(parentComment.depth == 0)
        #expect(childComment.depth == 1)
        #expect(grandchildComment.depth == 2)
    }
    
    @Test func testFriendRequestAcceptance() async throws {
        let sender = User(username: "sender", email: "sender@example.com", displayName: "Sender")
        let receiver = User(username: "receiver", email: "receiver@example.com", displayName: "Receiver")
        
        let friendRequest = FriendRequest(sender: sender, receiver: receiver)
        
        #expect(friendRequest.status == .pending)
        #expect(sender.friends.isEmpty)
        #expect(receiver.friends.isEmpty)
        
        friendRequest.accept()
        
        #expect(friendRequest.status == .accepted)
        #expect(sender.friends.count == 1)
        #expect(receiver.friends.count == 1)
        #expect(sender.friends.first?.id == receiver.id)
        #expect(receiver.friends.first?.id == sender.id)
    }
    
    @Test func testDuplicateFriendshipPrevention() async throws {
        let sender = User(username: "sender", email: "sender@example.com", displayName: "Sender")
        let receiver = User(username: "receiver", email: "receiver@example.com", displayName: "Receiver")
        
        sender.friends.append(receiver)
        receiver.friends.append(sender)
        
        let friendRequest = FriendRequest(sender: sender, receiver: receiver)
        friendRequest.accept()
        
        #expect(sender.friends.count == 1)
        #expect(receiver.friends.count == 1)
    }
    
    @Test func testMomentCreation() async throws {
        let user = User(username: "testuser", email: "test@example.com", displayName: "Test User")
        let moment = Moment(
            content: "Test moment with #hashtag",
            author: user,
            privacy: .friends
        )
        
        #expect(moment.content == "Test moment with #hashtag")
        #expect(moment.author?.id == user.id)
        #expect(moment.privacy == .friends)
        #expect(moment.likesCount == 0)
        #expect(moment.commentsCount == 0)
    }

}
