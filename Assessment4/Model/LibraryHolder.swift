//
//  LibraryHolder.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI
import CoreData

final class LibraryHolder: ObservableObject {
    @Published var categories: [Category] = []
    @Published var books: [Book] = []
    @Published var members: [Member] = []
    @Published var loans: [Loan] = []
    
    @Published var selectedCategory: Category? = nil
    @Published var searchText: String = ""
    
    init(_ context: NSManagedObjectContext) {
        refreshAll(context)
    }
    
    func refreshAll(_ context: NSManagedObjectContext) {
        refreshCategories(context)
        refreshBooks(context)
        refreshMembers(context)
        refreshLoans(context)
    }
    
    func refreshCategories(_ context: NSManagedObjectContext) {
        let request = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        categories = (try? context.fetch(request)) ?? []
    }
    
    func refreshBooks(_ context: NSManagedObjectContext) {
        let request = Book.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Book.title, ascending: true)]
        
        var predicates: [NSPredicate] = []
        if let cat = selectedCategory {
            predicates.append(NSPredicate(format: "category == %@", cat))
        }
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@ OR author CONTAINS[cd] %@", trimmedSearch, trimmedSearch))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        books = (try? context.fetch(request)) ?? []
    }
    
    func refreshMembers(_ context: NSManagedObjectContext) {
        let request = Member.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Member.name, ascending: true)]
        members = (try? context.fetch(request)) ?? []
    }
    
    func refreshLoans(_ context: NSManagedObjectContext) {
        let request = Loan.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Loan.borrowedAt, ascending: false)]
        loans = (try? context.fetch(request)) ?? []
    }
    
    func borrowBook(member: Member, book: Book, days: Int = 7, _ context: NSManagedObjectContext) {
        guard book.isAvailable else { return }
        let loan = Loan(context: context)
        loan.id = UUID()
        loan.borrowedAt = Date()
        loan.dueAt = Calendar.current.date(byAdding: .day, value: days, to: Date())
        loan.member = member
        loan.book = book
        book.isAvailable = false
        save(context)
    }
    
    func returnLoan(_ loan: Loan, _ context: NSManagedObjectContext) {
        loan.returnedAt = Date()
        loan.book?.isAvailable = true
        save(context)
    }
    
    func createBook(title: String, author: String, category: Category?, _ context: NSManagedObjectContext) {
        let newBook = Book(context: context)
        newBook.id = UUID()
        newBook.title = title
        newBook.author = author
        newBook.addedAt = Date()
        newBook.isAvailable = true
        newBook.category = category
        save(context)
    }
    
    func updateBook(book: Book, title: String, author: String, category: Category?, _ context: NSManagedObjectContext) {
        book.title = title
        book.author = author
        book.category = category
        save(context)
    }
    
    func deleteBook(_ book: Book, _ context: NSManagedObjectContext) {
        context.delete(book)
        save(context)
    }
    
    func createCategory(name: String, _ context: NSManagedObjectContext) {
        let newCategory = Category(context: context)
        newCategory.id = UUID()
        newCategory.name = name
        save(context)
    }
    
    func createMember(name: String, email: String, _ context: NSManagedObjectContext) {
        let newMember = Member(context: context)
        newMember.id = UUID()
        newMember.name = name
        newMember.email = email
        newMember.joinedAt = Date()
        save(context)
    }
    
    func deleteMember(_ member: Member, _ context: NSManagedObjectContext) {
        let activeLoans = member.loans?.allObjects as? [Loan] ?? []
        
        for loan in activeLoans {
            if loan.returnedAt == nil {
                loan.book?.isAvailable = true
            }
        }
        
        context.delete(member)
        save(context)
    }
    
    private func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            try? context.save()
            refreshAll(context)
        }
    }
}
