//
//  LoansView.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI

struct LoansView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    var body: some View {
        NavigationStack {
            Group {
                if holder.loans.isEmpty {
                    ContentUnavailableView("No Loan History", systemImage: "clock.badge.exclamationmark")
                } else {
                    List(holder.loans) { loan in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(loan.book?.title ?? "Unknown Book").font(.headline)
                                Text("Member: \(loan.member?.name ?? "Unknown")")
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(loan.returnedAt == nil ? "Active" : "Returned")
                                    .bold()
                                    .foregroundStyle(isOverdue(loan) ? .red : .primary)
                                
                                if let due = loan.dueAt {
                                    Text("Due: \(due, style: .date)").font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("All Loans")
            .onAppear { holder.refreshLoans(context) }
        }
    }
    
    private func isOverdue(_ loan: Loan) -> Bool {
        guard let due = loan.dueAt, loan.returnedAt == nil else { return false }
        return due < Date() 
    }
}

#Preview {
    LoansView()
}
