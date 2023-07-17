//
//  File.swift
//  
//
//  Created by osushi on 2023/07/17.
//

import Foundation

protocol AllStringSyntaxValidatorProtocol {
  func validate(allStringRawText: String) -> Result<Void, ValidationError>
}
