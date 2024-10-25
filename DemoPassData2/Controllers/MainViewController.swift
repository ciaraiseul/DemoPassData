import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var todos: [TodoItem] = []
    var newTodos: [TodoItem] = []
    var inProgressTodos: [TodoItem] = []
    var completedTodos: [TodoItem] = []
    
    var filteredTodos: [TodoItem] = []
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "TodoList"
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        navigationController?.navigationBar.titleTextAttributes = attributes

        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search To-dos"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        filterTodos()

        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = rightBarButtonItem

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")

        setupAutoLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func filterTodos() {
        todos = TodoManager.shared.getTodo()
        newTodos = todos.filter { $0.type == .new }
        inProgressTodos = todos.filter { $0.type == .inprogress }
        completedTodos = todos.filter { $0.type == .completed }
        tableView.reloadData()
    }

    @objc func didTapAddButton() {
        let createVC = CreateViewController()
        createVC.onCreate = { [weak self] data in
            guard let `self` = self else { return }
            TodoManager.shared.createTodo(data)
            self.filterTodos()
        }
        createVC.taskType = .new
        navigationController?.pushViewController(createVC, animated: true)
    }

    func setupAutoLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filterTodos()
            return
        }

        newTodos = todos.filter { $0.type == .new && ($0.title.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased())) }
        inProgressTodos = todos.filter { $0.type == .inprogress && ($0.title.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased())) }
        completedTodos = todos.filter { $0.type == .completed && ($0.title.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased())) }

        tableView.reloadData()
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            switch section {
            case 0:
                return newTodos.isEmpty ? 0 : newTodos.count
            case 1:
                return inProgressTodos.isEmpty ? 0 : inProgressTodos.count
            case 2:
                return completedTodos.isEmpty ? 0 : completedTodos.count
            default:
                return 0
            }
        } else {
            switch section {
            case 0:
                return newTodos.count
            case 1:
                return inProgressTodos.count
            case 2:
                return completedTodos.count
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            switch section {
            case 0:
                return newTodos.isEmpty ? nil : "New"
            case 1:
                return inProgressTodos.isEmpty ? nil : "Inprogress"
            case 2:
                return completedTodos.isEmpty ? nil : "Completed"
            default:
                return nil
            }
        } else {
            switch section {
            case 0:
                return "New"
            case 1:
                return "Inprogress"
            case 2:
                return "Completed"
            default:
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell

        let todo: TodoItem
        switch indexPath.section {
        case 0:
            todo = newTodos[indexPath.row]
        case 1:
            todo = inProgressTodos[indexPath.row]
        case 2:
            todo = completedTodos[indexPath.row]
        default:
            fatalError("Invalid section")
        }

        cell.todo = todo
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: TodoItem
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            switch indexPath.section {
            case 0:
                item = newTodos[indexPath.row]
            case 1:
                item = inProgressTodos[indexPath.row]
            case 2:
                item = completedTodos[indexPath.row]
            default:
                return
            }
        } else {
            switch indexPath.section {
            case 0:
                item = newTodos[indexPath.row]
            case 1:
                item = inProgressTodos[indexPath.row]
            case 2:
                item = completedTodos[indexPath.row]
            default:
                return
            }
        }

        let createVC = CreateViewController()
        createVC.item = item
        createVC.taskType = .update

        createVC.onCreate = { [weak self] data in
            guard let `self` = self else { return }
            TodoManager.shared.updateTodo(data)
            self.filterTodos()
        }

        navigationController?.pushViewController(createVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            guard let `self` = self else { return }
            let todo = self.todos[indexPath.row]
            TodoManager.shared.deleteTodo(todo)
            self.filterTodos()
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
