//
//  AuthRoute.swift
//  Case
//
//  Created by SAIL L1 on 02/03/26.
//


import Foundation

enum AuthRoute: Hashable {
    case forgotPassword
    case resetPassword(email: String)
}