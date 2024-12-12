
import UIKit
import FirebaseFirestore


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet var table:UITableView!
    @IBOutlet var label:UILabel!
    
    let db = Firestore.firestore()
    
    @IBAction func openChatGPT() {
        guard let chatVC = storyboard?.instantiateViewController(identifier: "GPT") as? ChatViewController else { return }

               chatVC.completion = { [weak self] response in
                   guard let self = self else { return }
                   let attributedResponse = NSAttributedString(string: response, attributes: [
                       .font: UIFont.systemFont(ofSize: 16),
                       .foregroundColor: UIColor.label
                   ])
                   
                   let currentDate = Date()
                   self.models.append((title: "GPT Ответ", note: attributedResponse, date: currentDate))
                   self.table.reloadData()
               }

               navigationController?.pushViewController(chatVC, animated: true)
           }

           var models: [(title: String, note: NSAttributedString, date: Date)] = [] {
               didSet {
                   saveNotesToLocal()
               }
           }
           var filteredModels: [(title: String, note: NSAttributedString, date: Date)] = []
           let searchBar = UISearchBar()

           override func viewDidLoad() {
               super.viewDidLoad()

               table.delegate = self
               table.dataSource = self
               table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

               title = "Блокнот"
               setupSearchBar()
               loadNotesFromFirestore()

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
                    let currentDate = Date()
                    self.models.append((title: noteTitle, note: note, date: currentDate))
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
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                let dateString = dateFormatter.string(from: model.date)

                cell.textLabel?.text = "\(model.title) (\(dateString))"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
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
                        let noteToDelete = self.models[index]
                        self.models.remove(at: index)
                        self.filteredModels.removeAll()
                        self.searchBar.text = ""
                        tableView.reloadData()
                        if self.models.isEmpty {
                            self.label.isHidden = false
                            self.table.isHidden = true
                        }

                        // Удаление из Firestore
                        self.db.collection("notes").document(noteToDelete.title).delete { error in
                            if let error = error {
                                print("Ошибка удаления: \(error)")
                            } else {
                                print("Заметка удалена из Firestore")
                            }
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

            // MARK: - Local Storage

            private func saveNotesToLocal() {
                let savedNotes = models.map { note -> [String: Any] in
                    [
                        "title": note.title,
                        "content": note.note.encodeToData() ?? Data(),
                        "date": note.date
                    ]
                }
                UserDefaults.standard.set(savedNotes, forKey: "savedNotes")
                saveNotesToFirestore()
                
            }

    private func saveNotesToFirestore(){
        for note in models{
            let noteData:[String:Any] = [
                "title":note.title,
                "content":note.note.string,
                "date":Timestamp(date: note.date)
            ]
            db.collection("notes").document(note.title).setData(noteData){error in
                if let error = error {
                    print("Ошибка сохранения: \(error)")
                } else {
                    print("Заметка сохранена")
                }
            }
        }
        
    }
    
            private func loadNotesFromLocal() {
                guard let savedNotes = UserDefaults.standard.array(forKey: "savedNotes") as? [[String: Any]] else { return }
                models = savedNotes.compactMap { noteDict in
                    guard let title = noteDict["title"] as? String,
                          let contentData = noteDict["content"] as? Data,
                          let content = NSAttributedString.decodeFromData(data: contentData),
                          let date = noteDict["date"] as? Date else { return nil }
                    return (title: title, note: content, date: date)
                }
                table.reloadData()
            }
    
    private func loadNotesFromFirestore() {
        db.collection("notes").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Ошибка загрузки данных: \(error)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            self.models = documents.compactMap { doc -> (title: String, note: NSAttributedString, date: Date)? in
                guard
                    let title = doc["title"] as? String,
                    let content = doc["content"] as? String,
                    let timestamp = doc["date"] as? Timestamp
                else {
                    return nil
                }
                return (title: title, note: NSAttributedString(string: content), date: timestamp.dateValue())
            }
            self.label.isHidden = !self.models.isEmpty
            self.table.isHidden = self.models.isEmpty
            self.table.reloadData()
        }
    }

    
        }



        // MARK: - Extensions for NSAttributedString

        extension NSAttributedString {
            func encodeToData() -> Data? {
                try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            }

            static func decodeFromData(data: Data) -> NSAttributedString? {
                try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSAttributedString
            }
        }
