import UIKit

class TodoManager {
    static let shared = TodoManager()
    
    private let userDefaultKey: String = "TodoItems"
    
    func getTodo() -> [TodoItem] {
        if let data = UserDefaults.standard.data(forKey: userDefaultKey) {
            if let todos = try? JSONDecoder().decode([TodoItem].self, from: data) {
                return todos
            }
        }
        return []
    }
    
    func createTodo(_ todo: TodoItem) {
        var todos = getTodo()
        todos.append(todo)
        saveTodos(todos)
    }
    
    func updateTodo(_ todo: TodoItem) {
        var todos = getTodo()
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveTodos(todos)
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        var todos = getTodo()
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos.remove(at: index)
            saveTodos(todos)
        }
    }
    
    private func saveTodos(_ todos: [TodoItem]) {
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(data, forKey: userDefaultKey)
        }
    }
}
