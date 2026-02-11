//
//  MembersView.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI


struct MemberDetailView: View {
    @ObservedObject var member: Member
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    @State private var selectedBook: Book?
    
    var body: some View {
        List {
            Section("Active Loans") {
                ForEach(holder.loans.filter { $0.member == member && $0.returnedAt == nil }) { loan in
                    HStack {
                        Text(loan.book?.title ?? "Book")
                        Spacer()
                        Button("Return") { holder.returnLoan(loan, context) }
                    }
                }
            }
            
            Section("Past Loans") {
                ForEach(holder.loans.filter { $0.member == member && $0.returnedAt != nil }) { loan in
                    HStack {
                        Text(loan.book?.title ?? "Book")
                        Spacer()
                        Text("Returned").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Borrow a Book") {
                Picker("Select Book", selection: $selectedBook) {
                    Text("Select a book").tag(nil as Book?)
                    ForEach(holder.books.filter { $0.isAvailable }) { book in
                        Text(book.title ?? "").tag(book as Book?)
                    }
                }
                
                Button("Confirm Borrow") {
                    if let book = selectedBook {
                        holder.borrowBook(member: member, book: book, context)
                        selectedBook = nil
                    }
                }
                .disabled(selectedBook == nil) 
            }
        }
        .navigationTitle(member.name ?? "Member")
    }
}



struct MembersView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @State private var showingAddMember = false
    
    var body: some View {
        NavigationStack {
            Group {
                if holder.members.isEmpty {
                    ContentUnavailableView("No Members", systemImage: "person.2.slash") 
                } else {
                    List {
                        ForEach(holder.members) { member in
                            NavigationLink(destination: MemberDetailView(member: member)) {
                                VStack(alignment: .leading) {
                                    Text(member.name ?? "Unknown").font(.headline)
                                    Text(member.email ?? "").font(.caption)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.map { holder.members[$0] }.forEach { holder.deleteMember($0, context) }
                        }
                    }
                }
            }
            .navigationTitle("Members")
            .toolbar {
                Button { showingAddMember = true } label: { Image(systemName: "person.badge.plus") }
            }
            .sheet(isPresented: $showingAddMember) {
                AddMemberView()
            }
            .onAppear { holder.refreshMembers(context) }
        }
    }
}

struct AddMemberView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var holder: LibraryHolder
    @Environment(\.managedObjectContext) var context
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
            }
            .navigationTitle("New Member")
            .toolbar {
                Button("Save") {
                    holder.createMember(name: name, email: email, context)
                    dismiss()
                }
                .disabled(name.isEmpty || email.isEmpty)
            }
        }
    }
}

#Preview {
    MembersView()
}
