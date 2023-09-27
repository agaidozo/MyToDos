//
//  FileManager+Extension.swift
//  MyToDos
//
//  Created by Obde Willy on 28/02/23.
//

import Foundation

let fileName = "ToDos.json"

extension FileManager {
    static var docDirURL: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveDocument(contents: String, docName: String, completion: (ToDoError?) -> Void) {
        let url = Self.docDirURL.appendingPathComponent(docName)
        
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            completion(.saveError)
        }
    }
    
    func readDocument(docName: String, completion: (Result<Data, ToDoError>) -> Void) {
        let url = Self.docDirURL.appendingPathComponent(docName)
        
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(.readError))
        }
    }
    
    func docExist(named docName: String) -> Bool {
        return fileExists(atPath: Self.docDirURL.appendingPathComponent(docName).path)
    }
}
