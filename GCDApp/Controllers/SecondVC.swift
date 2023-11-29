//
//  ViewController.swift
//  GCDApp
//
//  Created by Kate on 29/11/2023.
//

import UIKit

final class SecondVC: UIViewController {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var label: UILabel!
    
    private var timer: Timer?
    private let imageURL = URL(string: "https://commons.wikimedia.org/wiki/Main_Page#/media/File:Adelie_penguins_in_the_South_Shetland_Islands.jpg")
    
    private var image: UIImage? {
        get {
            imageView.image
        }
        set {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
            imageView.image = newValue
            imageView.sizeToFit()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImage()
    }

    private func fetchImage() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        // создаем очередь (utility - Служебные задачи имеют более низкий приоритет, чем стандартные, инициируемые пользователем и интерактивные задачи, но более высокий приоритет, чем фоновые задачи. Назначьте этот класс качества обслуживания задачам, которые не мешают пользователю продолжать использовать ваше приложение. Например, вы можете назначить этот класс длительным задачам, за ходом выполнения которых пользователь не следит активно.)
        // global - Возвращает глобальную системную очередь с заданным классом качества обслуживания.
        let queue = DispatchQueue.global(qos: .utility)
        // добавляем процесс асинхронно в другой поток
        queue.async { [weak self] in
            guard let self,
                  let url = self.imageURL,
                  let imageData = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: imageData)
                self.delay(3) {
                    self.loginAlert()
                }
            }
        }
    }
    
    private func delay(_ seconds: Int, closure: @escaping () -> ()) {
        // создаем задержку на seconds секунд с помощью asyncAfter
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
            closure()
        }
    }
    
    private func loginAlert() {
        let alertController = UIAlertController(title: "Вход в приложение", message: "Введите ваш логин и пароль", preferredStyle: .alert)
        /// Actions
        let okAction = UIAlertAction(title: "ОК", style: .default, handler: { [weak self] _ in
            guard let login = alertController.textFields?[0].text,
                  let pass = alertController.textFields?[1].text,
                  let self = self else { return }
            self.label.text = "\(login) \(pass)"
            self.timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        })
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        /// TextFields
        alertController.addTextField { usernameTF in
            usernameTF.placeholder = "Введите логин"
        }
        alertController.addTextField { userPasswordTF in
            userPasswordTF.placeholder = "Введите пароль"
            userPasswordTF.isSecureTextEntry = true
        }
        /// present
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func update() {
        let randomEmoji = self.randomEmoji()
        label.text = randomEmoji
        imageView.image = randomEmoji.image()
    }
    
    private func randomEmoji() -> String {
        let range = 0x1F300 ... 0x1F3F0
        let index = Int(arc4random_uniform(UInt32(range.count)))
        let ord = range.lowerBound + index
        guard let scalar = UnicodeScalar(ord) else { return "❓" }
        return String(scalar)
    }
    
    deinit {
        print("SecondVC deinit!!!")
    }
}

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 400, height: 400)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 360)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
