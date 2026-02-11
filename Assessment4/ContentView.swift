//
//  ContentView.swift
//  Assessment4
//
//  Created by netblen on 10-02-2026.
//

import SwiftUI
import CoreData

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BooksView()
                .tabItem { Label("Books", systemImage: "book") }
            
            MembersView()
                .tabItem { Label("Members", systemImage: "person.2") }
            
            LoansView()
                .tabItem { Label("Loans", systemImage: "clock") } 
        }
    }
}
