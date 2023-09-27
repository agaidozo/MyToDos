//
//  ToDo.swift
//  MyToDos
//
//  Created by Obde Willy on 28/02/23.
//

import Foundation

struct ToDo: Identifiable, Codable {
    var id = UUID().uuidString
    var name: String
    var completed = false
    
    static var sampleData: [ToDo] {
        [
            ToDo(name: "Get Groceries"),
            ToDo(name: "Make Dr. Appointment", completed: true)
        ]
    }
}
