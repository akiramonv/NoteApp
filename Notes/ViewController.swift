
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet var table:UITableView!
    @IBOutlet var label:UILabel!
    
    
    @IBAction func openChatGPT() {
        guard let chatVC = storyboard?.instantiateViewController(identifier: "GPT") as? ChatViewController else { return }

                chatVC.completion = { [weak self] response in
                    guard let self = self else { return }
                    let attributedResponse = NSAttributedString(string: response, attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.label
                    ])
                    
                    self.models.append((title: "GPT Ответ", note: attributedResponse))
                    self.table.reloadData()
                }

                navigationController?.pushViewController(chatVC, animated: true)
            }

            var models: [(title: String, note: NSAttributedString)] = []
            var filteredModels: [(title: String, note: NSAttributedString)] = []
            let searchBar = UISearchBar()

            override func viewDidLoad() {
                super.viewDidLoad()
                
                table.delegate = self
                table.dataSource = self
                table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                
                title = "Блокнот"
                setupSearchBar()
                
                label.text = "Нет заметок"
                label.isHidden = !models.isEmpty
                table.isHidden = models.isEmpty
            }

            func setupSearchBar() {
                searchBar.delegate = self
                searchBar.placeholder = "Поиск заметок"
                navigationItem.titleView = searchBar
            }
    @IBAction func didTapNewNote(){
        guard let vc = storyboard?.instantiateViewController(identifier: "new") as? EntryViewController else { return }
                vc.title = "Новая запись"
                
                vc.completion = { [weak self] noteTitle, note in
                    guard let self = self else { return }
                    self.models.append((title: noteTitle, note: note))
                    self.label.isHidden = true
                    self.table.isHidden = false
                    self.table.reloadData()
                }
                
                navigationController?.pushViewController(vc, animated: true)
            }

            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return filteredModels.isEmpty ? models.count : filteredModels.count
            }

            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                let model = filteredModels.isEmpty ? models[indexPath.row] : filteredModels[indexPath.row]
                cell.textLabel?.text = model.title
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                return cell
            }

            func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                tableView.deselectRow(at: indexPath, animated: true)
                let model = filteredModels.isEmpty ? models[indexPath.row] : filteredModels[indexPath.row]
                guard let vc = storyboard?.instantiateViewController(identifier: "note") as? NoteViewController else { return }
                vc.title = "Запись"
                vc.noteTitle = model.title
                vc.note = model.note
                navigationController?.pushViewController(vc, animated: true)
            }

            func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                if editingStyle == .delete {
                    let alert = UIAlertController(title: "Удалить заметку", message: "Вы уверены, что хотите удалить эту заметку?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
                        guard let self = self else { return }
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

            // MARK: - UISearchBarDelegate

            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                filteredModels = searchText.isEmpty ? [] : models.filter {
                    $0.title.lowercased().contains(searchText.lowercased()) ||
                    $0.note.string.lowercased().contains(searchText.lowercased())
                }
                table.reloadData()
            }

            func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
                searchBar.text = ""
                filteredModels.removeAll()
                table.reloadData()
                searchBar.resignFirstResponder()
            }
        }
