
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet var table:UITableView!
    @IBOutlet var label:UILabel!
    
    // Массив для хранения заметок, каждая заметка представлена парой "заголовок" и "содержание"
        var models: [(title: String, note: String)] = []
        var filteredModels: [(title: String, note: String)] = [] // Отфильтрованные данные для поиска

        let searchBar = UISearchBar() // Элемент для ввода поискового запроса

        override func viewDidLoad() {
            super.viewDidLoad()
            // Установка делегата и источника данных для таблицы
            table.delegate = self
            table.dataSource = self
            
            // Регистрация стандартной ячейки для таблицы
            table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            
            // Установка заголовка экрана
            title = "Блокнот"
            
            setupSearchBar()
        }
        
    // Настройка UISearchBar
        func setupSearchBar() {
            searchBar.delegate = self
            searchBar.placeholder = "Поиск заметок"
            navigationItem.titleView = searchBar // Устанавливаем поисковую строку в заголовок
        }
    
    // Метод, вызываемый при нажатии на кнопку добавления новой записи
    @IBAction func didTapNewNote(){
        // Переход к экрану добавления новой записи
        guard let vc = storyboard?.instantiateViewController(identifier: "new") as? EntryViewController else {
                    return
                }
                vc.title = "Новая запись"
                vc.navigationItem.largeTitleDisplayMode = .never
                
                vc.completion = { noteTitle, note in
                    self.navigationController?.popToRootViewController(animated: true)
                    self.models.append((title: noteTitle, note: note))
                    self.label.isHidden = true
                    self.table.isHidden = false
                    self.table.reloadData()
                }
                navigationController?.pushViewController(vc, animated: true)
            }

            // MARK: - Методы UITableViewDataSource

            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return filteredModels.isEmpty ? models.count : filteredModels.count
            }

            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                let model = filteredModels.isEmpty ? models[indexPath.row] : filteredModels[indexPath.row]
                cell.textLabel?.text = model.title
                cell.detailTextLabel?.text = model.note
                return cell
            }

            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                tableView.deselectRow(at: indexPath, animated: true)
                let model = filteredModels.isEmpty ? models[indexPath.row] : filteredModels[indexPath.row]
                guard let vc = storyboard?.instantiateViewController(identifier: "note") as? NoteViewController else {
                    return
                }
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.title = "Запись"
                vc.noteTitle = model.title
                vc.note = model.note
                navigationController?.pushViewController(vc, animated: true)
            }

            func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                if editingStyle == .delete {
                    let alert = UIAlertController(title: "Удалить заметку", message: "Вы уверены, что хотите удалить эту заметку?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                    
                    alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
                        let index = self.filteredModels.isEmpty ? indexPath.row : self.models.firstIndex(where: { $0.title == self.filteredModels[indexPath.row].title })!
                        self.models.remove(at: index)
                        self.filteredModels.removeAll()
                        self.searchBar.text = ""
                        tableView.reloadData()
                        if self.models.isEmpty {
                            self.label.isHidden = false
                            self.table.isHidden = true
                        }
                    }))
                    
                    present(alert, animated: true)
                }
            }
// Rjv
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                // Фильтрация данных
                filteredModels = searchText.isEmpty
                    ? []
                    : models.filter { $0.title.lowercased().contains(searchText.lowercased()) }
                table.reloadData()
            }

            func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
                // Очистка поиска
                searchBar.text = ""
                filteredModels.removeAll()
                table.reloadData()
                searchBar.resignFirstResponder()
            }
        }
