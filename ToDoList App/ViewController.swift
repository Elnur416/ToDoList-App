//
//  ViewController.swift
//  ToDoList App
//
//  Created by Elnur Mammadov on 19.12.24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var table: UITableView!
    
    let context = AppDelegate().persistentContainer.viewContext
    private var items = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "To Do List"
        table.dataSource = self
        table.delegate = self
        getAllItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAdd))
    }

    @objc func didTapAdd() {
        let alert = UIAlertController(title: "New Item",
                                      message: "Enter New Item",
                                      preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }
            self?.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }
    
    //MARK: - Core Data
    func getAllItems() {
        do {
             items = try context.fetch(ToDoListItem.fetchRequest())
            table.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }

    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName

        do {
            try context.save()
            getAllItems()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK: - UI Configuration
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let sheet = UIAlertController(title: "Edit",
                                      message: nil,
                                      preferredStyle: .actionSheet)
       
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Item",
                                          message: "Edit your item",
                                          preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else { return }
                self?.updateItem(item: item, newName: newName)
            }))
            
            self.present(alert, animated: true)
            
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
            self?.deleteItem(item: item)
        }))

            present(sheet, animated: true)
    }
}
