//  
//  ViewController.swift
//  Translate
//  Using Swift 4.0
//
//  Created by Abhishek Singh on 18/01/19.
//  Copyright © 2019 NGA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sourceBackView: UIView!
    @IBOutlet weak var selectSourceButton: UIButton!
    @IBOutlet weak var sourceTextView: UITextView!
    @IBOutlet weak var targetBackView: UIView!
    @IBOutlet weak var targetSourceButton: UIButton!
    @IBOutlet weak var targetTextView: UITextView!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Translate", comment: "Translate")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAppView()
    }
    
    func setAppView() {
        
        activityView.layer.cornerRadius = 5
        activityView.layer.masksToBounds = true
        targetTextView.isEditable = false
        sourceBackView.layer.cornerRadius = 5
        sourceBackView.layer.masksToBounds = true
        selectSourceButton.layer.cornerRadius = 5
        selectSourceButton.layer.masksToBounds = true
        sourceTextView.layer.cornerRadius = 2.5
        sourceTextView.layer.masksToBounds = true
        targetBackView.layer.cornerRadius = 5
        targetBackView.layer.masksToBounds = true
        targetSourceButton.layer.cornerRadius = 5
        targetSourceButton.layer.masksToBounds = true
        targetTextView.layer.cornerRadius = 2.5
        targetTextView.layer.masksToBounds = true
        translateButton.layer.cornerRadius = 5
        translateButton.layer.masksToBounds = true
        clearButton.layer.cornerRadius = 5
        clearButton.layer.masksToBounds = true
    }
    
    @IBAction func sourceSelectAction(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        let alert = UIAlertController(title: "Select One", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "en", style: UIAlertAction.Style.default, handler: { (action) in
            button.setTitle("en", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "fr", style: UIAlertAction.Style.default, handler: { (action) in
            button.setTitle("fr", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "zh", style: UIAlertAction.Style.default, handler: { (action) in
            button.setTitle("zh", for: .normal)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func targetSelectAction(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        let alert = UIAlertController(title: "Select One", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "en", style: UIAlertAction.Style.default, handler: { (action) in
            button.setTitle("en", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "fr", style: UIAlertAction.Style.default, handler: { (action) in
            button.setTitle("fr", for: .normal)
        }))
        alert.addAction(UIAlertAction(title: "zh", style: UIAlertAction.Style.default, handler: { (action) in
            button.setTitle("zh", for: .normal)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func translateAction(_ sender: Any) {
        guard let sourceText = sourceTextView.text, sourceText != "" else {
            let alert = UIAlertController(title: "Error", message: "Empty source", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        //translateAPI(sourceText: sourceText)
        activityView.isHidden = false
        translateAPI(source: selectSourceButton.titleLabel?.text ?? "fr", target: targetSourceButton.titleLabel?.text ?? "fr", sourceText: sourceText) { (response) in
            if let respDict = response as? [String: Any], let data = respDict["data"] as? [String: Any], let translations = data["translations"] as? [[String: String]], translations.count > 0 {
                DispatchQueue.main.async {
                    self.targetTextView.text = translations[0]["translatedText"] ?? ""
                    self.activityView.isHidden = true
                }
            }
        }
    }
    
    @IBAction func clearAction(_ sender: Any) {
        sourceTextView.text = ""
        targetTextView.text = ""
    }
    
    func translateAPI(source: String, target:String, sourceText: String, callback:@escaping (_ response: Any) -> Void) {
        let key="API Key"
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let postData = NSMutableData(data: "format=text".data(using: String.Encoding.utf8)!)
        postData.append("&source=\(source)".data(using: String.Encoding.utf8)!)
        postData.append("&target=\(target)".data(using: String.Encoding.utf8)!)
        postData.append("&q=\(sourceText)".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://translation.googleapis.com/language/translate/v2?key=\(key)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error?.localizedDescription ?? "Error")
                callback(error?.localizedDescription ?? "Error")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse?.statusCode ?? 00)
                do{
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                        data!, options: [])
                    print(jsonResponse) //Response result
                    callback(jsonResponse)
                } catch let parsingError {
                    print("Error", parsingError)
                    callback (parsingError.localizedDescription)
                }
            }
        })
        
        dataTask.resume()
    }
    
}

