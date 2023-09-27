//
//  MyToDosApp.swift
//  MyToDos
//
//  Created by Obde Willy on 28/02/23.
//

import SwiftUI

@main
struct MyToDosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DataStore())
        }
    }
}
