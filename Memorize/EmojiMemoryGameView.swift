//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by 芦满 on 2022/4/16.
//


// View
import SwiftUI

struct EmojiMemoryGameView: View {
    /*
     语法说明：
     body是一个计算属性，类型约束"some View" 代表get的返回值是一个遵循了View协议的类型。
     因为计算属性的get只有一个语句，所以可以省略return。
     
     这里不对 game(ViewModel) 赋值，而是在MemorizeApp.swift实例化ContentView的时候，
     将具体的参数传递进来。
     
     在game前面 @ObservedObject 装饰器，目的是每次当viewObject发布有model发生变化的
     通知时，去接收这些通知，以便于反应到UI上。
     */
    @ObservedObject var game: EmojiMemoryGame
    
    var body: some View {
//        ScrollView {
//            /*
//             stroke() 只绘制边框
//             fill() 填充颜色
//             stroke和fill切换，可以实现类似于牌面翻转的效果。
//
//             这里省略了参数content的label，因为利用了swift尾闭包的特性。
//
//             注意lazyVGrid的参数语法。列数的控制，传入的是GridItem对象的数组，
//             而不是简单的数字，之所以这样，是因为GridItem对象可以更精细的控制列
//             的属性。数组中放几个GridItem实例，则每行显示几个。
//
//             在本例中，只写了一个GridItem，但是在参数中指定了最小宽度和最大宽度。剩下的，
//             由SwiftUI自己来决定每行能放置多少个View。这样可以兼容横屏。
//             */
//            LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))]) {
//                ForEach(game.cards) { card in
        AspectVGrid(item: game.cards, aspectRatio: 2/3, content: { card in
            CardView(card: card)
                .aspectRatio(2 / 3, contentMode: .fit)
                .onTapGesture {game.choose(card)}
        })
        
//                }
//            }
//        }
        .foregroundColor(.red)
        .padding(.horizontal)
    }
}

/// 卡片的封装
struct CardView: View {
    let card: EmojiMemoryGame.Card
    
    /*
     这个init()方法本来不需要，这里专门申明这个构造器方法，是为了在实例化CardView的
     时候，可以省略card参数名。
     */
    //    init(_ card: EmojiMemoryGame.Card){
    //        self.card = card
    //    }
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                // 判断牌面是否翻转
                if card.isFaceUp {
                    /*
                     在z轴上定义两个圆角矩形，下面的填充模式，前景白色。
                     上面的边框模式，前景红色。
                     这样做就可以较好的兼容白天模式和深夜模式。
                     */
                    shape.fill().foregroundColor(.white)
                    shape.strokeBorder(lineWidth: DrawingConstants.lineWidth )
                    Text(card.content)
                    /*
                     font()方法本来应该传入一个Font对象，但是因为语句太长，写在这里不美观，所以作者提取出一个函数，
                     用于生成Font对象。
                     
                     因为卡牌本身宽高是不一样的，但是牌面内容的宽高比又可能和卡牌不一致，
                     这样就会导致内充又可能在某一个方向撑爆卡牌。为了避免这种情况，这里
                     使用了min()函数，从GeometryReader容器的建议宽高中，挑出一个较小的，
                     作为内容的font size。
                     */
                        .font(font(in: geometry.size))
                    // 被找出匹配的图片，隐藏起来。
                }else if card.isMatched{
                    shape.opacity(0)
                }else {
                    shape.fill()
                }
            }
        })
    }
    
    /*
     通过一个CGSize类型的对象，生成一个Font类型的对象。
     写这个方法，完全是因为避免调用位置写一行太长的代码，个人认为多此一举！
     */
    private func font(in size: CGSize) -> Font{
        /*
         只有一个语句的函数，可以省略return。
         这里的DrawingConstants.fontScale是一个magic number，为了美观考虑。
         */
        Font.system(size: min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    /*
     统一管理所有常量
     */
    private struct DrawingConstants{
        static let cornerRadius: CGFloat = 20  // 这里的类型约束不能省略，否则swift会自动将20推导为Int类型。
        static let lineWidth: CGFloat = 3
        static let fontScale: CGFloat = 0.8
    }
}

// 右侧Preview相关的代码
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
        EmojiMemoryGameView(game: game)
            .preferredColorScheme(.dark)
        
    }
}

