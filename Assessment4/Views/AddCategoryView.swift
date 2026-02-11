//
//  AddCategoryView.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var holder: LibraryHolder
    @State private var categoryName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Category Name", text: $categoryName)
            }
            .navigationTitle("New Category")
            .toolbar {
                Button("Save") {
                    holder.createCategory(name: categoryName, context)
                    dismiss()
                }
                .disabled(categoryName.isEmpty)
            }
        }
    }
}
#Preview {
    AddCategoryView()
}
