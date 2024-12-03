import UIKit

class ChatViewController: UIViewController {
    @IBOutlet var chatHistoryTextView: UITextView!
    @IBOutlet var userInputTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    // Замыкание для возврата ответа в EntryViewController
    public var completion: ((String) -> Void)?

        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Chat"
            chatHistoryTextView.isEditable = false // Блокируем редактирование истории
        }
    
    @IBAction func sendButtonTapped() {
        // Извлечение текста из текстового поля
                guard let userInput = userInputTextField.text, !userInput.isEmpty else {
                    print("Текстовое поле пустое")
                    return
                }
                
                // Добавляем запрос в историю чата
                chatHistoryTextView.text += "\n\nYou: \(userInput)"
                userInputTextField.text = "" // Очищаем поле после отправки
                
                // Отправка запроса к Hugging Face
                fetchHFResponse(for: userInput) { [weak self] response in
                    DispatchQueue.main.async {
                        // Добавляем ответ в историю чата
                        self?.chatHistoryTextView.text += "\n\nAssistant: \(response)"
                        self?.completion?(response) // Передача ответа обратно
                    }
                }
            }
            
    func fetchHFResponse(for prompt: String, completion: @escaping (String) -> Void) {
        let apiKey = Secrets.openAIKey
        let url = URL(string: "https://api-inference.huggingface.co/models/facebook/blenderbot-400M-distill")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let parameters: [String: Any] = [
            "inputs": prompt
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion("Ошибка: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("Ошибка: Нет данных от сервера.")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Ответ от API: \(jsonString)")
            }

            do {
                // Парсим JSON
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    if let generatedText = jsonArray.first?["generated_text"] as? String {
                        completion(generatedText.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        completion("Не удалось извлечь ключ 'generated_text'. JSON: \(jsonArray)")
                    }
                } else {
                    completion("Формат ответа не соответствует массиву JSON.")
                }
            } catch {
                completion("Ошибка при обработке JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

        }
