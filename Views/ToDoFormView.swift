//
//  ToDoFormView.swift
//  MyToDos
//
//  Created by Obde Willy on 28/02/23.
//

import SwiftUI

struct ToDoFormView: View {
    @EnvironmentObject var dataStore: DataStore
    @ObservedObject var formVM: ToDoFormViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusField: Field?
    
    enum Field {
        case todoName
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading) {
                    TextField("ToDo", text: $formVM.name)
                        .focused($focusField, equals: .todoName)
                    
                    Toggle("Completed", isOn: $formVM.completed)
                }
            }
            .navigationTitle("ToDo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: updateSaveButton)
            .task {
                focusField = .todoName
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button {
                        focusField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
    }
}

extension ToDoFormView {
    func updateToDo() {
        let toDo = ToDo(id: formVM.id!, name: formVM.name, completed: formVM.completed)
        dataStore.updateToDo.send(toDo)
        dismiss()
    }
    
    func addToDo() {
        let toDo = ToDo(name: formVM.name)
        dataStore.addToDo.send(toDo)
        dismiss()
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    var updateSaveButton: some View {
        Button(formVM.updating ? "Update" : "Save") {
            formVM.updating ? updateToDo() : addToDo()
        }
        .disabled(formVM.isDisabled)
    }
}

struct ToDoFormView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoFormView(formVM: ToDoFormViewModel())
            .environmentObject(DataStore())
    }
}
