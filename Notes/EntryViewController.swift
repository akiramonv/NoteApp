
import UIKit

class EntryViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var noteField: UITextView!
    
    // Замыкание для передачи данных новой заметки обратно в основной контроллер
        public var completion: ((String, String) -> Void)?

        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Установка фокуса на поле для ввода заголовка при загрузке экрана
            titleField.becomeFirstResponder()
            
            // Добавление кнопки "Сохранить" в навигационную панель
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Сохранить",
                style: .done,
                target: self,
                action: #selector(didTapSave)
            )

            // Настройка внешнего вида текстового поля для заметки
            noteField.layer.borderColor = UIColor.lightGray.cgColor // Цвет рамки
            noteField.layer.borderWidth = 1.0 // Толщина рамки
            noteField.layer.cornerRadius = 8.0 // Скругление углов
        }

        // Метод, вызываемый при нажатии на кнопку "Сохранить"
        @objc func didTapSave() {
            // Проверка, что оба поля заполнены
            if let text = titleField.text, !text.isEmpty, !noteField.text.isEmpty {
                // Передача данных заметки через замыкание
                completion?(text, noteField.text)
                
                // Возврат к предыдущему экрану
                navigationController?.popViewController(animated: true)
            } else {
                // Показ предупреждения, если поля не заполнены
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Пожалуйста, заполните все строки",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
            }
        }
    }
