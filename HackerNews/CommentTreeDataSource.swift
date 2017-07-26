//
//  CommentTreeDataSource.swift
//  HackerNews
//
//  Created by Alex Choi on 7/19/17.
//  Copyright © 2017 Alex Choi. All rights reserved.
//


struct CommentTreeDataSource {
    
    // MARK: - INTERFACE
    
    var commentsCount: Int {
        return flattenedTree.count
    }
    
    init(comments: [Comment] = []) {
        tree = comments.map { CommentNode(comment: $0) }
        flattenedTree = CommentTreeDataSource.flatten(tree: tree)
    }
    
    func comment(atIndex index: Int) -> Comment {
        return flattenedTree[index].comment
    }
    
    func isCommentExpanded(atIndex index: Int) -> Bool {
        return flattenedTree[index].isExpanded
    }
    
    mutating func setCommentIsExpanded(_ isExpanded: Bool, atIndex index: Int) {
        guard let treeItem = treeItemForFlattenedIndex(index: index) else {
            return
        }
        treeItem.isExpanded = isExpanded
        flattenedTree = flatten(tree: tree)
    }
    
    mutating func expandComment(atIndex index: Int) {
        setCommentIsExpanded(true, atIndex: index)
    }
    
    mutating func collapseComment(atIndex index: Int) {
        setCommentIsExpanded(false, atIndex: index)
    }
    
    // MARK: - PRIVATE
    
    private class CommentNode {
        
        var isExpanded = true
        let children: [CommentNode]
        let descendantIds: Set<Int>
        
        let comment: Comment
        
        init(comment: Comment) {
            self.comment = comment
            self.children = comment.children.map { CommentNode(comment: $0) }
            
            var descendantIds = Set<Int>()
            for child in children {
                descendantIds.insert(child.comment.id)
                descendantIds = descendantIds.union(child.descendantIds)
            }
            
            self.descendantIds = descendantIds
        }
        
        func hasDescendant(withId id: Int) -> Bool {
            return descendantIds.contains(id)
        }
        
        static func findRecursively(nodes: [CommentNode], id: Int) -> CommentNode? {
            for node in nodes {
                if node.comment.id == id {
                    return node
                }
                if node.hasDescendant(withId: id) {
                    return findRecursively(nodes: node.children, id: id)
                }
            }
            return nil
        }
    }
    
    private let tree: [CommentNode]
    private var flattenedTree: [CommentNode] // flattened representation of tree, excluding all descendants of any collapsed nodes
    
    private static func flatten(tree: [CommentNode]) -> [CommentNode] {
        return tree.map {(comment) -> [CommentNode] in
            guard comment.isExpanded else {
                return [comment]
            }
            return [comment] + flatten(tree: comment.children)
            }.flatMap { $0 }
    }
    
    private func flatten(tree: [CommentNode]) -> [CommentNode] {
        return CommentTreeDataSource.flatten(tree: tree)
    }
    
    private func treeItemForFlattenedIndex(index: Int) -> CommentNode? {
        let commentId = flattenedTree[index].comment.id
        return CommentNode.findRecursively(nodes: tree, id: commentId)
    }
}
