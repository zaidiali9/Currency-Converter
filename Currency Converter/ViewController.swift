//
//  ViewController.swift
//  Currency Converter
//
//  Created by Ali Hassan on 24/04/2025.
//

import UIKit




class ViewController: UIViewController {
    
    @IBOutlet weak var currencyConverted: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var popupbutton1: UIButton!
    @IBOutlet weak var popupbutton2: UIButton!
    
    @IBOutlet weak var currencyOne: UITextField!
    @IBOutlet weak var currencyTwo: UITextField!
    
    var currencyCodes: [String] = []
    var currencyRates: [String: Double] = [:]
    
    var toCurrency: String = ""
    var fromCurrency: String = ""
    
    var intractor: CurrencyBussinessLogic?
    
    
    func setup(){
        let presenter = Presenter()
        let interactor = Interactor()
        presenter.viewController = self
        interactor.presenter = presenter
        self.intractor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        uiFixes()
        
        Task {
            
            if let intractor {
                self.currencyCodes = await intractor.getCurrencyCodes()
            }
            
            configureButtonMenus()
            
            do {
                if let intractor {
                    self.currencyRates = try await intractor.fetchExchangeRates(for: self.currencyCodes)
                }
            } catch {
                print("Failed to fetch rates: \(error)")
            }
        }
    }
    
    private func uiFixes() {
        stackView.layer.cornerRadius = 20
        self.currencyConverted.text = ""
    }
    
    private lazy var optionClosure1: (UIAction) -> Void = { action in
        self.fromCurrency = action.title
    }
    private lazy var optionClosure2: (UIAction) -> Void = { action in
        self.toCurrency = action.title
    }
    
    
    
    private func configureButtonMenus() {
        var uiActions1 = [UIAction]()
        var uiActions2 = [UIAction]()
        
        for code in self.currencyCodes {
            let action = UIAction(title: code, state: .off, handler: optionClosure1)
            uiActions1.append(action)
        }
        
        for code in self.currencyCodes {
            let action = UIAction(title: code, state: .off, handler: optionClosure2)
            uiActions2.append(action)
        }
        popupbutton1.menu = UIMenu(children: uiActions1)
        popupbutton1.showsMenuAsPrimaryAction = true
        
        popupbutton2.menu = UIMenu(children: uiActions2)
        popupbutton2.showsMenuAsPrimaryAction = true
    }
    
    
    @IBAction func convertCurrency(_ sender: Any) {
        self.currencyConverted.text = ""
        intractor?.convertCurrency(fromText: self.currencyOne.text, fromCurrency: self.fromCurrency, toCurrency: self.toCurrency, rates: self.currencyRates)
    }
    
   
    
}


extension ViewController: CurrencyDisplayLogic {
    func showConvertedValue(value: String){
        self.currencyTwo.text = value
    }
}
