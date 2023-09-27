//
//  ContentView.swift
//  MyToDos
//
//  Created by Obde Willy on 28/02/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var modalType: ModalType? = nil
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataStore.toDos.value) { toDo in
                    Button {
                        modalType = .update(toDo)
                    } label: {
                        Text(toDo.name)
                            .font(.title3)
                            .strikethrough(toDo.completed)
                            .foregroundColor(toDo.completed ? .green : Color(.label))
                    }
                }
                .onDelete(perform: dataStore.deleteToDo.send) 
            }
            .listStyle(.insetGrouped)
            .navigationTitle("My ToDos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        modalType = .new
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(item: $modalType) { $0 }
            .alert("File Error",
                   isPresented: $dataStore.showErrorAlert,
                   presenting: dataStore.appError.value) { appError in
                appError.button
            } message: { appError in
                Text(appError.message)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataStore())
    }
}
