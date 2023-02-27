//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Георгий Негурица on 7/1/23.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showResult(result: AlertModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.message,
                                      preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "resultAlert"
        let alertAction = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        
        alert.addAction(alertAction)
        
        delegate?.presentAlert(alert: alert)
    }
}

