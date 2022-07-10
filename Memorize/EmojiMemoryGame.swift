//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by 芦满 on 2022/4/20.
//

import SwiftUI

/*
 ViewModel
 
 在这个类中，choose() 方法会修改 model 的属性，这直接需要反映到UI中（卡牌翻面），需要UI即时生效的
 方法，就是让这个类遵循 ObservableObject 协议，并且在变更前，调用 objectWillChange.send()
 方法，告诉系统监听变化。
 更简单的方法，是在有可能变化的属性前，使用 @Published 装饰器。每次被装饰得属性发生修改时，都
 发出通知，告知其他组件，这个属性发生变化了。
 然后在View中，还需要给 viewModel 添加 @ObservedObject
 */
class EmojiMemoryGame: ObservableObject {
    /*
     类型别名（type alias） 声明可以在程序中为一个既有类型声明一个别名。
     这里使用别名，是为了简化下面代码的长度。不用也不影响功能。
     */
    typealias Card = MemoryGame<String>.Card
    
    /*
     属性的初始化完成之后，实例才具有self引用。
     
     如果这里不用static修饰，下面初始化model时，函数使用了emojis[pairIndex]会报错。
     经static修饰的属性，是“类型属性”，不再是“实例属性”，该属性会在类型初始化的时候，就初始化，
     远远早于实例的初始化。
     */
    private static let emojis: Array<String> = ["🚗", "✈️", "🛵", "🚢", "🚅", "🚉",
                                   "🛴", "🚲", "🛺", "🚨", "🚔", "🚍",
                                   "🚘", "🚖", "🚡", "🚠", "🚟", "🚃",
                                   "🚋", "🚞", "🚝", "🚄", "🚈", "🚂",
                                   "🚆", "🚇", "🚊"]
 
    // 创建MemoryGame实例的方法。
    private static func createMemoryGame() -> MemoryGame<String> {
        MemoryGame<String>(numOfPairsOfCards: 4) { pairIndex in
            emojis[pairIndex]
        }
    }

    /*
     函数作为参数时，有几点需要注意：
     1、函数不需要名称。
     2、整个函数体用花括号包裹。
     3、不需要声明参数及返回值的类型（在MemoryGame的init方法定义时，已经声明）。
     4、"in"关键子作为参数名称和具体函数体的分隔符号。
     5、如果只有一个参数，包裹参数的括号也可以省略。
     6、如果只有一个参数，参数名称可以用"_"代替。
     7、如果函数是最后一个参数，可以将函数体从圆括号中提取到最语句的最末尾。

     下面是原始的语句：
     private var model: MemoryGame<String> =
        MemoryGame<String>(numOfPairsOfCards: 4,
        createCardContent:{ (index: Int) in "😀" })

     上面语句的最简化写法：
     private var model: MemoryGame<String> =
        MemoryGame<String>(numOfPairsOfCards: 4) { _ in "😀" }
     */
    @Published private var model: MemoryGame<String> = createMemoryGame()

    // cards是只读计算属性
    var cards: Array<Card> {
        model.cards
    }
       
    
    // 调用Model的choose方法，处理具体的点击事件。
    func choose(_ card: Card){
        model.choose(card)
    }
}
