//
//  SegueHandler.swift
//  Eventhogh
//
//  Created by Gareth Fong on 31/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit

protocol ETSegueHandler {
    
    associatedtype SegueIdentifier: RawRepresentable
}

extension ETSegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegueWithIdentifier(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    
    func segueIdentifierForName(name: String) -> SegueIdentifier {
        guard let identifier = SegueIdentifier(rawValue: name) else { fatalError("Invalid segue `\(name)`.") }
        return identifier
    }
    
    func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let name = segue.identifier else { fatalError("Segue has empty identifier!") }
        return segueIdentifierForName(name: name)
    }
}
