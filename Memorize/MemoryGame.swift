//
//  MemoryGame.swift
//  Memorize
//
//  Created by 芦满 on 2022/4/19.
//

import Foundation

/*
 Model
 抽象了MemoryGame的结构：
    cards数组，用于存储所有的卡牌。
    choose方法，点选卡牌的处理函数。
    Card的结构体：
        isFaceUp:是否牌面朝上
        isMatched: 是否匹配
 */
struct MemoryGame<CardContent> where CardContent: Equatable {
    // 只读属性，只能通过choose来改变，外界不能直接修改cards的值。
    private(set) var cards: Array<Card>

    // 定义为Optional，因为在游戏的开始，该值没有被定义
    private var indexOfTheOneAndOnlyFaceUpCard: Int?

    /*
     卡牌点击的处理函数
     struct是不可变的，如果非要修改自身的属性，需要在方法前加上mutating关键字。
     */
    mutating func choose(_ card: Card) {
        /*
         因为所有函数的参数都是不可变的，所以不能直接将card的isFaceUp赋值，实际上我们要操作的
         card，是上面定义的数组cards中的一员，所以要先获取这个card的index，然后去操作
         cards。

         if let是因为index()方法返回的是Optinal
         */

        /*
         Array内建的方法，找到某元素的index，参数是一个function，要求定义比较的条件。
         $0是闭包的第一个参数。
         遍历cards，找到第一个id和card.id相同的元素。
         */
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                indexOfTheOneAndOnlyFaceUpCard = nil
            } else {
                // cards.indices等同于0..<cards.count
                for index in cards.indices {
                    cards[index].isFaceUp = false
                }
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }

            // Bool的toggle方法可以用于Bool类型的切换。
            cards[chosenIndex].isFaceUp.toggle()
        }
    }

    /*
     第三个参数是一个函数，用于生成牌面的内容。调用者实例化MemoryGame<CardContent>实例的
     时候，需要传入这个函数。
     MemoryGame<CardContent>并不知道，也不关心具体实例化时，生成何种卡牌类型，所以在声明
     这个类的时候，使用了泛型。同样的，init方法，也需要由调用者来决定具体CardContent生成的
     具体方法。
     需要注意的是，调用者仅仅提供生成CardContent的具体函数实现，而生成的过程，还是在这里完成。
     PS：EmojiMemoryGame生成的CardContent是String类型，PokerMemoryGame（不存在）生成
     的CardContent类型是Image。
      */
    init(numOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = Array<Card>()
        // add numOfPairsOfCards * 2 cards to "cards" array.
        for pairIndex in 0 ..< numOfPairsOfCards {
            let content: CardContent = createCardContent(pairIndex)
            // 这里添加两次，是因为每对牌都有相同的两张。
            cards.append(Card(id: pairIndex * 2, content: content))
            cards.append(Card(id: pairIndex * 2 + 1, content: content))
        }
    }

    // 在ContentView中，cards需要被foreach遍历，要求遵循Identifiable协议。
    struct Card: Identifiable {
        // Identifiable协议要求具有ObjectIdentifier属性。
        var id: Int

        var isFaceUp: Bool = false
        var isMatched: Bool = false
        /*
         CardContent是一个泛型，在struct声明的位置有写。
         如果在结构体中使用泛型，需要在声明的时候，将所有泛型的名称写在<>内。
         */
        var content: CardContent
    }
}
