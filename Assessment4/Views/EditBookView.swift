//
//  EditBookView.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI

struct EditBookView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var holder: LibraryHolder
    
    @ObservedObject var book: Book
    
    @State private var title: String
    @State private var author: String
    @State private var selectedCategory: Category?
    
    init(book: Book) {
        self.book = book
        _title = State(initialValue: book.title ?? "")
        _author = State(initialValue: book.author ?? "")
        _selectedCategory = State(initialValue: book.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Book Title", text: $title)
                TextField("Author", text: $author)
                Picker("Category", selection: $selectedCategory) {
                    Text("None").tag(nil as Category?)
                    ForEach(holder.categories) { cat in
                        Text(cat.name ?? "").tag(cat as Category?)
                    }
                }
            }
            .navigationTitle("Edit Book")
            .toolbar {
                Button("Update") {
                    if !title.isEmpty && !author.isEmpty {
                        holder.updateBook(book: book, title: title, author: author, category: selectedCategory, context)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    let mockBook = Book(context: context)
    mockBook.title = "test Book"
    mockBook.author = "test Author"
    
    return EditBookView(book: mockBook)
        .environmentObject(LibraryHolder(context))
}
