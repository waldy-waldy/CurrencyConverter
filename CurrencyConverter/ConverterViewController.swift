//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by neoviso on 9/3/21.
//

import UIKit

class ConverterViewController: UIViewController {

    @IBOutlet weak var checkButton: UIButton!
    var currencyList = [CurrencyEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "PrimaryColor")
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "BackgroundColor")]
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
