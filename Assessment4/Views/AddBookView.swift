//
//  AddBookView.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI

struct AddBookView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var holder: LibraryHolder
    
    @State private var title = ""
    @State private var author = ""
    @State private var selectedCategory: Category?
    
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
            .navigationTitle("Add New Book")
            .toolbar {
                Button("Save") {
                    if !title.isEmpty && !author.isEmpty {
                        holder.createBook(title: title, author: author, category: selectedCategory, context)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddBookView()
}
