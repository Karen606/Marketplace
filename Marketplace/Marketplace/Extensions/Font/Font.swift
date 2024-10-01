//
//  Font.swift
//  Marketplace
//
//  Created by Karen Khachatryan on 01.10.24.
//

import UIKit


extension UIFont {
    static func regular(size: CFloat) -> UIFont? {
        return UIFont(name: "SFProText-Regular", size: CGFloat(size))
    }
    
    static func medium(size: CFloat) -> UIFont? {
        return UIFont(name: "SFProText-Medium", size: CGFloat(size))
    }
    
    static func semibold(size: CFloat) -> UIFont? {
        return UIFont(name: "SFProText-Semibold", size: CGFloat(size))
    }
    
    static func bold(size: CFloat) -> UIFont? {
        return UIFont(name: "SFProText-Bold", size: CGFloat(size))
    }
    
    static func regularItalic(size: CFloat) -> UIFont? {
        return UIFont(name: "SFProText-RegularItalic", size: CGFloat(size))
    }
    
    static func mediumItalic(size: CFloat) -> UIFont? {
        return UIFont(name: "SFProText-MediumItalic", size: CGFloat(size))
    }
    
    static func light(size: CFloat) -> UIFont? {
        return UIFont(name: "SFProText-Light", size: CGFloat(size))
    }
    
    static func lightItalic(size: CFloat) -> UIFont? {
        return UIFont(name: "SFProText-LightItalic", size: CGFloat(size))
    }
}
