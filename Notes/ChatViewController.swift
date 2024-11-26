import UIKit

class ChatViewController: UIViewController {
    @IBOutlet var chatHistoryTextView: UITextView!
    @IBOutlet var userInputTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    // Замыкание для возврата ответа в EntryViewController
    public var completion: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ChatGPT"
        chatHistoryTextView.isEditable = false // Блокируем редактирование истории
    }

    @IBAction func sendButtonTapped() {
        guard let userInput = userInputTextField.text, !userInput.isEmpty else { return }
        
        chatHistoryTextView.text += "\n\nYou: \(userInput)"
        userInputTextField.text = ""

        // Отправка запроса к GPT
        fetchGPTResponse(for: userInput) { [weak self] response in
            DispatchQueue.main.async {
                self?.chatHistoryTextView.text += "\n\nGPT: \(response)"
                self?.completion?(response) // Передача ответа обратно
            }
        }
    }
    
    
    
    func fetchGPTResponse(for prompt: String, completion: @escaping (String) -> Void) {
        let apiKey = Secrets.openAIKey
        let url = URL(string: "https://api.openai.com/v1/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let parameters: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": prompt,
            "max_tokens": 150
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Ошибка: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let text = choices.first?["text"] as? String {
                completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                completion("Не удалось обработать ответ.")
            }
        }
        
        task.resume()
    }
}
