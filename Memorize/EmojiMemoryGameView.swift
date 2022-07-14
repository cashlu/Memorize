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
        VStack{
            gameBody
            shuffle
        }
        .padding()
    }
    
    // 将游戏卡牌的主体部分抽离出来
    var gameBody: some View{
        AspectVGrid(items: game.cards, aspectRatio: 2/3){ card in
            if card.isMatched && !card.isFaceUp{
                // 如果两张牌匹配上了，就隐藏起来。
//                Rectangle().opacity(0)
                // 下面的代码可以实现相同的效果
                Color.clear
            }else{
                CardView(card: card)
                    .padding(4)
                    .onTapGesture {
                        // 让卡牌的翻转，加上动画效果
                        withAnimation(.easeInOut(duration: 3  )){
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor( .red)
    }
    
    // “Shuffle”按钮的View
    var shuffle: some View{
        Button("Shuffle"){
            // 给打乱牌组添加默认的动画效果
            withAnimation{
                game.shuffle()
            }
        }
    }
}

// 卡片的封装
struct CardView: View {
    let card: EmojiMemoryGame.Card
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                // 注意：Angle的0角度，不是12点，是3点方向。所以绘制的时候，减去90度。
                Pie(startAngel: Angle(degrees: 0-90), endAngle: Angle(degrees: 110-90))
                    .padding(5).opacity(0.5)
                Text(card.content)
                /*
                 rotationEffect（旋转效果）的作用是告诉动画系统，当某个条件值满足时，Text从状态A变化为状态B，
                 但是rotationEffect并不负责动画的部分。具体的动画效果，由animation来负责。所以如果没有animation的话，
                 totationEffect的效果会瞬间体现。
                 
                 总结：
                 动画效果有两个条件，一个是对象在动画前后的两个状态，二是运动的方式和时长。
                 本例中，rotationEffect声明了旋转的两个角度，animation负责声明运动方式和时长。
                 */
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                /*
                 在课程中，使用的是.animation(Animation)这个方法，但是我们这里使用了.adnimation(Animation, value)，
                 因为前者在swiftui 3.0后被弃用。此版本的 animation 会与所在视图层次和该视图层次的子节点的所有依赖项进行状态关联。
                 视图和它子节点中的任何依赖项发生变化，都将满足启用动画插值计算的条件，并动画数据传递给作用范围内（视图和它子节点）
                 的所有可动画部件。
                 如下例：
                 Circle()
                     .fill(red ? .red : .blue)
                     .frame(width: 30, height: 30)
                     .offset(x: x)
                     .animation(.easeInOut(duration: 1)) // 同时关联了 x 和 red 两个依赖项
                 不论red还是x，任何一个依赖项满足条件，fill和offset的动画都会被触发。
                 */
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: card.isMatched)
                /*
                 font()方法本来应该传入一个Font对象，但是因为语句太长，写在这里不美观，所以作者提取出一个函数，
                 用于生成Font对象。
                 
                 因为卡牌本身宽高是不一样的，但是牌面内容的宽高比又可能和卡牌不一致，
                 这样就会导致内充又可能在某一个方向撑爆卡牌。为了避免这种情况，这里
                 使用了min()函数，从GeometryReader容器的建议宽高中，挑出一个较小的，
                 作为内容的font size。
                 */
                    .font(font(in: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
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
        static let fontScale: CGFloat = 0.7
    }
}

// 右侧Preview相关的代码
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        // 把第一张牌翻开，以便于测试
//        game.choose(game.cards.first!)
        return EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
    }
}

