//
//  CurrencyConverterViewController.swift
//  Currency Converter
//
//  Created by Ali Hassan on 28/04/2025.
//

import UIKit

protocol CurrencyDisplayLogic{
    func showConvertedValue(value: String)
}

class CurrencyConverterViewController: UIViewController {

    
    // IBOutlet
    
    @IBOutlet weak var currencyFrom: UIButton!
    
    @IBOutlet weak var codeLabelfrom: UILabel!
    @IBOutlet weak var fromText: UITextField!
    
    @IBOutlet weak var currencyTo: UIButton!
    
    @IBOutlet weak var codeLabelto: UILabel!
    
    @IBOutlet weak var toText: UITextField!
    
    @IBAction func convertCurrency(_ sender: Any) {
        intractor?.convertCurrency(fromText: self.fromText.text, fromCurrency: self.fromCurrency, toCurrency: self.toCurrency, rates: self.currencyRates)
    }
    
    // Required Data
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
        currencyFrom.menu = UIMenu(children: uiActions1)
        currencyFrom.showsMenuAsPrimaryAction = true
        
        currencyTo.menu = UIMenu(children: uiActions2)
        currencyTo.showsMenuAsPrimaryAction = true
    }
    
    private lazy var optionClosure1: (UIAction) -> Void = { action in
        self.fromCurrency = action.title
        
        self.codeLabelfrom.text = action.title
    }
    private lazy var optionClosure2: (UIAction) -> Void = { action in
        self.toCurrency = action.title
        self.codeLabelto.text = action.title
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
  
}

extension CurrencyConverterViewController: CurrencyDisplayLogic {
    func showConvertedValue(value: String){
        self.toText.text = value
    }
}
