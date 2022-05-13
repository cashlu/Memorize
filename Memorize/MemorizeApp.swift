//
//  MemorizeApp.swift
//  Memorize
//
//  Created by 芦满 on 2022/4/16.
//

import SwiftUI

@main
struct MemorizeApp: App {
    /*
     EmojiMemoryGame是一个class。
     类和结构体在创建实例时，必须为所有存储型属性设置合适的初始值。存储型属性的值不能处于一个
     未知的状态。
     这里没有在实例化时传入参数，是因为EmojiMemoryGame的所有属性，在类定义的时候，都有初始值。
     
     另外，这里的game使用了let来声明，但是明显game的属性在未来是需要修改状态的，这里并没有错，
     因为EmojiMemoryGame是class，class是引用类型，game是一个指针，没有修改指针本身的值。
     */
    let game = EmojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: game)
        }
    }
}
