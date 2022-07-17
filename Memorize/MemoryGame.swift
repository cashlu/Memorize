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
 
 结构体申明时的<CardContent>是一个泛型，CardContent并不是某一个特定的类型，只是一个“占位符”，
 之所以要写这个占位符，是因为需要约束该类型必须遵循Equatable协议。
 */
struct MemoryGame<CardContent> where CardContent: Equatable {
    // 只读属性，只能通过choose来改变，外界不能直接修改cards的值。
    private(set) var cards: Array<Card>
    
    /*
     当前翻开的卡牌的index。游戏规则每次只能翻开一张卡片。
     申明为 private 是因为，这个属性在外部任何地方都不能这修改，只能被当前结构体的 choose() 方法修改。
     定义为Optional，因为在游戏的开始，该值没有被定义。
     
     第二版将此属性修改为计算属性，通过遍历cards数组，当只有一个卡牌是faceUp时，则该属性为这个卡牌的index，否则为nil，
     这样可以确保该属性的正确性。计算属性的特性时，当每次程序访问这个属性时，都会进行计算。
     同时，每当这个属性发生修改时，使用set逻辑，确保只有一个牌面是faceUp的，确保逻辑的正确性。
     */
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get{
            /*
             初始化所有faceUp的index数组，这里调用了cards.indices.filter方法。filter方法的参数是indices()方法
             返回的index数组。filter()方法的要求传入一个闭包，返回Bool类型，以便于判断传入值是否最终返回出去。
             */
            let faceUpCardIndices = cards.indices.filter({ cards[$0].isFaceUp })
            /*
             Array本没有oneAndOnly属性，下面通过swift的extension语法，扩展了Array的功能和属性。
             oneAndOnly代表的是faceUpCardIndices数组中只有一个值时，这个唯一的值。如果faceUpIndices数组中的元素
             不唯一，则返回nil。(逻辑看具体扩展的实现逻辑，很简单。)
             这里使用extension，并非业务需要，只是为了练习。
             */
            return faceUpCardIndices.oneAndOnly
        }
        set{
            cards.indices.forEach{cards[$0].isFaceUp = ($0 == newValue)}
        }
    }
    /*
     卡牌点击的处理函数。
     struct是不可变的，如果非要修改自身的属性，需要在方法前加上mutating关键字。
     */
    mutating func choose(_ card: Card) {
        /*
         swift 函数的参数默认是“传值”，所以不能直接修改参数card的isFaceUp的状态。
         而正是因为swift“传值”的特性，这里这里传入的card，也是真正的“卡牌”的副本，
         实际上我们要操作的card，是上面定义的数组cards中的一员，所以要先获取这个card的index，
         然后去操作cards，而不是直接操作传入的参数。
         
         firstIndex()是Array内建的方法，找到某元素的index，参数是一个function，要求定义比较的条件。
         $0是闭包的第一个参数，firstIndex()方法只有一个参数，就是每次遍历时的元素。
         遍历cards数组，找到第一个id和card.id相同的元素。
         
         这里的if let语句，等号后面的条件有三个，用逗号隔开，这是swift的语法糖，要三个条件都满足才行。
         在这里，分别要满足三个条件：
         1、cards数组中找到的第一个id和card.id相等的元素。
         2、找到的该元素的isFaceUp属性必须为false。
         3、该元素的isMatched属性必须为false。
         */
        if let chosenIndex: Int = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,    // 已经翻开的卡牌不能点击
           !cards[chosenIndex].isMatched {  // 已经被匹配的卡牌不能点击
            /*
             这里如果indexOfTheOneAndOnlyFaceUpCard有值（不为Optional），这赋值给potentialMatchIndex。
             注意这里的potentialMatchIndex变量的作用域，仅在后面的花括号中。
             */
            if let potentialMatchIndex: Int = indexOfTheOneAndOnlyFaceUpCard {
                // 如果翻开的两张牌的content相同，则将两张牌的isMatched设置为true
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                cards[chosenIndex].isFaceUp = true
                /*
                 如果 indexOfTheOneAndOnlyFaceUpCard 为 nil，代表当前翻开的是第一张牌，那么将所有卡牌的isFaceUp全部设置为false
                 然后将 indexOfTheOneAndOnlyFaceUpCard 赋值为当前翻开卡牌的Index。
                 
                 每次翻牌，在if/else外面，统一将点击的牌面翻转，因为不论是否匹配成功，或者这次点击是否是第一张牌，这张牌都需要展示出来。
                 */
            } else {
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    /*
     将卡牌重新排列
     */
    mutating func shuffle(){
        // shuffle()是数组的内置方法。
        cards.shuffle()
    }
    
    /*
     MemoryGame的构造器方法。
     
     numOfPairsOfCards: 一共有几对卡牌
     createCardContent: 这是一个函数，参数为Int类型，返回值是CardContent类型。该函数的作用
     是根据具体的游戏类型，来生成不同的牌面内容。同样通过调用MemoryGame的构造器方法来实例化
     具体游戏对象的时候，EmojiMemoryGame生成的CardContent是String类型，
     PokerMemoryGame（不存在）生成的CardContent类型是Image。
     
     在MemoryGame的init()方法中，只是申明要有createCardContent(Int) -> CardContent方法，
     但具体的方法实现，由调用者来提供。这点在逻辑上也很合理，不同的调用者，才知道具体应该使用何种
     牌面类型。EmojiMemoryGame自己知道需要的牌面类型是Emoji表情（String），PokerMemoryGame
     只有自己知道，需要生成的牌面类型是Image，MemoryGame这个Struct的开发者（或者开发的时刻），
     并不知道到底有多少种牌面的类型，所以把生成牌面的实现留给调用者，是很合理的。
     
     另外，前面已经说过，CardContent是一个泛型占位符，并不是一个具体的类型，在MemoryGame这个结构体
     申明的时候，约定CardContent必须遵循Equatable协议，也就是说，任何一个遵循Equatable协议的
     类型，都可以作为返回值。
     */
    init(numOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = Array< Card>()
        // add numOfPairsOfCards * 2 cards to "cards" array.
        for pairIndex in 0 ..< numOfPairsOfCards {
            let content: CardContent = createCardContent(pairIndex)
            // 这里添加两次，是因为每对牌都有相同的两张。
            cards.append(Card(id: pairIndex * 2, content: content))
            cards.append(Card(id: pairIndex * 2 + 1, content: content))
        }
        // 初始化后的卡牌组，顺序是按照读取数组的顺序创建的，所以需要在初始化的时候，打乱顺序。
        cards.shuffle()
    }
    
    // 在ContentView中，cards需要被foreach遍历，要求遵循Identifiable协议。
    struct Card: Identifiable {
        // Identifiable协议要求具有ObjectIdentifier属性。
        let id: Int
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        /*
         content代表的是卡牌的牌面样式。
         这里只是申明了content属性为CardContent类型，但实际上CardContent仅是一个泛型的占位符，并不是一个实际的类型。
         可以这样理解，实际的业务需求上，MemoryGame只是定义了游戏的基础构成，但是细节方面并没有约定，例如卡牌排面的样式、
         卡牌数量的多寡等，这些需要在EmojiMemoryGame实例化的时候，才能确定。
         */
        let content: CardContent
    }
}

/*
 扩展原生的Array数组功能，添加一个oneAndOnly属性，以便于本项目使用。
 */
extension Array{
    /*
     Element是Array的泛型，具体可通过查看Array的文档或者源码得知。
     oneAndOnly属性是Optional类型，因为该属性有可能是nil。
     */
    var oneAndOnly: Element?{
        if count == 1{
            return first
        }else{
            return nil
        }
    }
}
