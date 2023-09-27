//
//  DataStore.swift
//  MyToDos
//
//  Created by Obde Willy on 28/02/23.
//

import Foundation
import Combine

class DataStore: ObservableObject {
    var toDos = CurrentValueSubject<[ToDo], Never>([])
    var appError = CurrentValueSubject<ErrorType?, Never>(nil)
    var addToDo = PassthroughSubject<ToDo, Never>()
    var updateToDo = PassthroughSubject<ToDo, Never>()
    var deleteToDo = PassthroughSubject<IndexSet, Never>()
    var subscriptions = Set<AnyCancellable>()
    var loadToDos = Just(FileManager.docDirURL.appendingPathComponent(fileName))
    
    @Published var showErrorAlert = false
    
    init() {
        print(FileManager.docDirURL.path)
        addSubscriptions()
    }
    
    func addSubscriptions() {
        loadToDosSubscription()
        addToDoSubscription()
        deleteToDoSubscription()
        updateToDoSubscription()
        appErrorSubscription()
    }
    
    func appErrorSubscription() {
        appError
            .sink { _ in
                self.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }
    
    func toDosSubscription() {
        toDos
            .subscribe(on: DispatchQueue(label: "background queue"))
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .encode(encoder: JSONEncoder())
            .tryMap { data in
                try data.write(to: FileManager.docDirURL.appendingPathComponent(fileName))
            }
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    print("Saving Completed")
                case .failure(let error):
                    if error is ToDoError {
                        appError.send(ErrorType(error: error as! ToDoError))
                        showErrorAlert = true
                    } else {
                        appError.send(ErrorType(error: ToDoError.encodingError))
                        showErrorAlert = true
                    }
                }
            } receiveValue: { _ in
                print("Saving file was successful")
            }
            .store(in: &subscriptions)
    }
    
    func addToDoSubscription() {
        addToDo.sink { [unowned self] toDo in
            self.objectWillChange.send()
            toDos.value.append(toDo)
        }
        .store(in: &subscriptions)
    }
    
    func updateToDoSubscription() {
        updateToDo
            .sink { [unowned self] toDo in
                guard let index = toDos.value.firstIndex(where: { $0.id == toDo.id }) else { return }
                self.objectWillChange.send()
                toDos.value[index] = toDo
            }
            .store(in: &subscriptions)
    }
    
    func deleteToDoSubscription() {
        deleteToDo
            .sink { [unowned self] indexSet in
                toDos.value.remove(atOffsets: indexSet)
                self.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }
    
    func loadToDosSubscription() {
        loadToDos
            .filter { FileManager.default.fileExists(atPath: $0.path) }
            .tryMap { url in
                
                try Data(contentsOf: url)
                
            }
            .decode(type: [ToDo].self, decoder: JSONDecoder())
            .subscribe(on: DispatchQueue(label: "background queue"))
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                
                switch completion {
                    
                case .finished:
                    print("Loading")
                    toDosSubscription()
                    
                case .failure(let error):
                    
                    if error is ToDoError {
                        appError.send(ErrorType(error: error as! ToDoError))
                        showErrorAlert = true
                        
                    } else {
                        appError.send(ErrorType(error: ToDoError.decodingError))
                        showErrorAlert = true
                        toDosSubscription()
                    }
                }
                
            } receiveValue: { toDos in
                self.objectWillChange.send()
                self.toDos.value = toDos
                
            }
            .store(in: &subscriptions)
    }
}
