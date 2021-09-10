//
//  StartScreenViewController.swift
//  CurrencyConverter
//
//  Created by neoviso on 9/3/21.
//

import UIKit
import MBProgressHUD
import Alamofire
import CoreData

class CurrencyInfo {
    var code: String
    var rate: Double
    var name: String
    
    init(code: String, rate: Double, name: String){
        self.code = code
        self.rate = rate
        self.name = name
    }
}

class StartScreenViewController: UIViewController {

    //OUTLETS
    
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cancelExitButton: UIButton!
    @IBOutlet var MainView: UIView!

    //VARIABLES
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let url = "https://www.floatrates.com/daily/byn.json"
    var currencyValues: [CurrencyInfo] = [CurrencyInfo]()
    var currencyList = [CurrencyEntity]()
    var itemsCount = 0

    //VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestToAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    //ACTIONS
    
    @IBAction func repeatButtonDidTap(_ sender: Any) {
        hideButtons()
        requestToAPI()
    }
    
    @IBAction func cancelExitButtonDidTap(_ sender: Any) {
        hideButtons()
        if (itemsCount == 0){
            exit(0)
        }
    }
    
    //API
        
    func requestToAPI() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading..."
        DispatchQueue.main.async {
            AF.request(self.url).responseJSON { [self] response in
                switch response.result {
                    case .success(let value):
                        if let data = value as? [String: Any] {
                            clearItems()
                            createItem(newItem: CurrencyInfo(code: "BYN", rate: 1.00, name: "Belarussian Ruble"))
                            for item in data.keys {
                                let info = data[item] as? [String: Any]
                                let code = info?["code"] as! String
                                let name = info?["name"] as! String
                                let rate = info?["inverseRate"] as! Double
                                let currencyTemp = CurrencyInfo(code: code, rate: rate, name: name)
                                createItem(newItem: currencyTemp)
                            }
                        }
                        loadingNotification.hide(animated: true)
                        goToTheNextPage()
                    case .failure(_):
                        loadingNotification.hide(animated: true)
                        showButtons()
                }
            }
        }
    }
        
    //PAGE
    
    func goToTheNextPage(){
        let converterViewController = storyboard?.instantiateViewController(identifier: "ConverterViewController")
        navigationController?.pushViewController(converterViewController!, animated: true)
    }
    
    //BUTTONS VISIBILITY
    
    func showButtons() {
        self.messageLabel.isHidden = false
        self.repeatButton.isHidden = false
        self.cancelExitButton.isHidden = false
        getItemsCount()
        if (itemsCount == 0){
            cancelExitButton.setTitle("Выйти из приложения", for: .normal)
        }
        else {
            cancelExitButton.setTitle("Отменить запрос", for: .normal)
        }
    }
        
    func hideButtons() {
        self.messageLabel.isHidden = true
        self.repeatButton.isHidden = true
        self.cancelExitButton.isHidden = true
    }
    
    //CORE DATA
    
    func getItemsCount(){
        do {
            itemsCount = try context.fetch(CurrencyEntity.fetchRequest()).count
        }
        catch {
            
        }
    }
        
    func clearItems() {
        do {
            let items = try context.fetch(CurrencyEntity.fetchRequest()) as! [NSManagedObject]
            for item in items {
                context.delete(item)
            }
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
        
    func createItem(newItem: CurrencyInfo) {
        let tempItem = CurrencyEntity(context: context)
        tempItem.code = newItem.code
        tempItem.rate = newItem.rate
        tempItem.name = newItem.name
        
        do {
            try context.save()
        }
        catch {
            context.rollback()
        }
    }
}
