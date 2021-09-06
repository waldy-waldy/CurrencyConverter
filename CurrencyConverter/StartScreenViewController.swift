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
    var currencyName: String
    var isSell: Bool
    var currencyValue: Double
    
    init(currencyName: String, isSell: Bool, currencyValue: Double) {
        self.currencyName = currencyName
        self.isSell = isSell
        self.currencyValue = currencyValue
    }
}

class StartScreenViewController: UIViewController {

    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cancelExitButton: UIButton!
    @IBOutlet var MainView: UIView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let url = "https://belarusbank.by/api/kursExchange"
    var currencyValues: [CurrencyInfo] = [CurrencyInfo]()
    var currencyList = [CurrencyEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestToAPI()             
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        requestToAPI()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func repeatButtonDidTap(_ sender: Any) {
        hideButtons()
        requestToAPI()
    }
    
    @IBAction func cancelExitButtonDidTap(_ sender: Any) {
        hideButtons()
        getAllItems()
        if (currencyList.count == 0){
            exit(0)
        }
        else {
            performSegue(withIdentifier: "showConverterPage", sender: self)
            //go to next page
            /*
            for item in checkArray {
                print(item.currencyName! + " ------- " + String(item.currencyValue))
            }
            */
        }
    }
    
    func requestToAPI() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading..."
        AF.request(self.url).responseJSON { [self] response in
            switch response.result {
                case .success(let value):
                    if let res = value as? [[String: String]] {
                        if let data = res[0] as [String: String]? {
                            for elem in data {
                                if let rate = Double(elem.value) {
                                    var sell = true
                                    if (elem.key.contains("in")){
                                        sell = false
                                    }
                                    let currencyTemp = CurrencyInfo(currencyName: elem.key, isSell: sell, currencyValue: rate)
                                    createItem(newItem: currencyTemp)
                                    currencyValues.append(currencyTemp)
                                }
                            }
                            loadingNotification.hide(animated: true)
                            //performSegue(withIdentifier: "showConverterPage", sender: self)
                            showButtons()
                        }
                        else {
                            loadingNotification.hide(animated: true)
                            showButtons()
                        }
                    }
                    else {
                        loadingNotification.hide(animated: true)
                        showButtons()
                    }
                case .failure(_):
                    loadingNotification.hide(animated: true)
                    showButtons()
            }
        }
    }
        
    func showButtons() {
        self.messageLabel.isHidden = false
        self.repeatButton.isHidden = false
        self.cancelExitButton.isHidden = false
    }
        
    func hideButtons() {
        self.messageLabel.isHidden = true
        self.repeatButton.isHidden = true
        self.cancelExitButton.isHidden = true
    }
        
    func getAllItems() {
        do {
            currencyList = try context.fetch(CurrencyEntity.fetchRequest())
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
            
        }
    }
        
    func createItem(newItem: CurrencyInfo) {
        let tempItem = CurrencyEntity(context: context)
        tempItem.currencyName = newItem.currencyName
        tempItem.isSell = newItem.isSell
        tempItem.currencyValue = newItem.currencyValue
        
        do {
            try context.save()
        }
        catch {
                
        }
    }
        
    func deleteItem(deleteItem: CurrencyEntity) {
        context.delete(deleteItem)
            
        do {
            try context.save()
        }
        catch {
                
        }
    }
        
    func updateItem(updateItem: CurrencyEntity, newItem: CurrencyInfo) {
        updateItem.currencyName = newItem.currencyName
        updateItem.isSell = newItem.isSell
        updateItem.currencyValue = newItem.currencyValue
            
        do {
            try context.save()
        }
        catch {
                
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConverterViewController {
            destination.currencyList = currencyList
        }
    }
}
