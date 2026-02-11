//
//  BooksView.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI

struct BooksView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    @State private var showingAddSheet = false
    @State private var showingAddCategory = false
    @State private var bookToEdit: Book?
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search title or author...", text: $holder.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onChange(of: holder.searchText) { holder.refreshBooks(context) }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("All") {
                            holder.selectedCategory = nil
                            holder.refreshBooks(context)
                        }.buttonStyle(.bordered)
                        
                        ForEach(holder.categories) { cat in
                            Button(cat.name ?? "") {
                                holder.selectedCategory = cat
                                holder.refreshBooks(context)
                            }.buttonStyle(.bordered)
                        }
                        
                        Button(action: { showingAddCategory = true }) {
                            Image(systemName: "folder.badge.plus")
                        }.buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
                
                if holder.books.isEmpty {
                    ContentUnavailableView("No Books Found", systemImage: "book.closed")
                } else {
                    List {
                        ForEach(holder.books) { book in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(book.title ?? "Unknown").font(.headline)
                                    Text(book.author ?? "Unknown author").font(.subheadline)
                                }
                                Spacer()
                                Text(book.isAvailable ? "Available" : "Borrowed")
                                    .foregroundStyle(book.isAvailable ? .green : .red)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { bookToEdit = book }
                        }
                        .onDelete { indexSet in
                            indexSet.map { holder.books[$0] }.forEach { holder.deleteBook($0, context) }
                        }
                    }
                }
            }
            .navigationTitle("Library Books")
            .toolbar {
                Button { showingAddSheet = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showingAddSheet) { AddBookView() }
            .sheet(isPresented: $showingAddCategory) { AddCategoryView() }
            .sheet(item: $bookToEdit) { book in EditBookView(book: book) }
            .onAppear { holder.refreshAll(context) }
        }
    }
}

#Preview {
    BooksView()
        .environmentObject(LibraryHolder(PersistenceController.shared.container.viewContext))
}
