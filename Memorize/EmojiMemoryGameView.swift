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
    @Namespace private var dealingNameSpace
    
    var body: some View {
        ZStack(alignment: .bottom){
            VStack{
                gameBody
                HStack{
                    restart
                    Spacer()
                    shuffle
                }
                .padding(.horizontal)
            }
            deckBody
        }
        .padding()
    }
    
    @State private var dealt = Set<Int>()
    
    private func deal(_ card: EmojiMemoryGame.Card){
        dealt.insert(card.id)
    }

    private func isUnDealt(_ card: EmojiMemoryGame.Card) -> Bool{
        // isUnDealt，结果要取反
        !dealt.contains(card.id)
    }
    
    /*
     说明：
     在绘制deck区卡牌的时候，因为所有卡牌都是重叠在一起的，所以最先进入ZStack的CardView，就会在最下面（压栈），最上面的一张卡牌，是最后放
     进去的，等到卡牌从deck区飞向gameBody区的时候，由于也是根据数组原先的顺序，显示的效果，就是deck区域的最上面一张牌始终不动，从最下面开始
     出牌，这样的显示效果不理想，我们希望从最上面一张开始，deck区的牌堆嘴上的一张牌，随着发牌的过程，始终在不停的变化。
     
     gameBody的CardView和deckBody的CardView两个地方，分别调用了zIndex()函数。外面的zIndex()函数，是swift自带的方法。里面作为参数的
     zIndex函数，是这里自己定义的。
     swift自带的zIndex函数，接受一个Double类型的参数value。当两个View重叠的时候，value大的那个，会显示在上方。
     这里我们又自己定义了一个zIndex()函数，用于给每张在deck区的卡牌，生成自己的zIndex value，生成的规则，是按照卡牌数组现有顺序的倒序来排
     列，具体的逻辑，是读取每张牌index，取index的负数，这样越靠前的牌，负数index就越小，就会排在越下方。
     
     而之所以在gameBody和deckBody两个地方的CardView都调用zIndex，是因为要让这两个区域的顺序一致。（存疑）
     */
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double{
        -Double(game.cards.firstIndex(where: {$0.id == card.id}) ?? 0)
    }
    
    /*
     根据牌组中，每张卡牌的index，来对每张卡牌指定不同的动画延迟，这样做的效果是，卡牌从deck飞向gameBody的时候，是一张一张飞出去的。
     totalDealDuration是整个动画过程的时长，除以卡牌的数量，就得到了每张卡牌能平均分配到的时间，再乘以index，就是没张牌开始动画的delay。
     */
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation{
        var delay = 0.0
        if let index = game.cards.firstIndex(where: {$0.id == card.id}){
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    // 将游戏卡牌的主体部分抽离出来
    var gameBody: some View{
        /*
         在AspectVGrid的声明中，items数组的类型和闭包参数类型是相同的泛型，所以这里items的cards对应闭包实参card。
         AspectVGrid只是负责了卡牌没有翻开之前的布局排列、间距。但是并不负责具体的卡牌样式。卡牌两面的背景、前景、倒计时用的Pie等元素样式
         由CardView负责。
         */
        AspectVGrid(items: game.cards, aspectRatio: 2/3){ card in
            if isUnDealt(card) || (card.isMatched && !card.isFaceUp){
                /*
                 如果两张牌匹配上了，就隐藏起来。
                 Rectangle().opacity(0)
                 下面的代码可以实现相同的效果
                 */
                Color.clear
            }else{
                CardView(card: card)
                /*
                 matchedGeometryEffect实现了卡牌从下方deck，飞到gameBody中的效果。
                 在没有matchedGeometryEffect的时候，如果我们要实现一个动画效果，我们需要明确的告诉View移动的速度，位移的距离等，
                 但是有了matchedGeometryEffect，我们只需要定义好动画前后的两个状态View，当两个View要进行切换时，
                 matchedGeometryEffect会自动的对动画进行插值，实现效果。
                 使用的方法，就是在前后两个状态的 View 中，都添加下面这个语句。
                 
                 注意：matchedGeometryEffect不能实现颜色的动画切换。颜色的切换是一瞬间的。
                 */
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                    .padding(4)
                /* scale代表缩放效果，easeinOut代表运动方式（加速度曲线）
                 .transition(AnyTransition.scale.animation(Animation.easeInOut(duration: 2)))
                 
                 非对称过场效果，入场用scale，出场用opacity。这里入场效果看不出来，因为CardView一直都存在。
                 如果只是简单的在这里定义过场动画，入场动画是不会有效果的。因为这些CardView并没有从容器AspectVGrid中出现或消失，
                 在渲染AspectVGrid的时候，这些CardView已经在AspectVGrid中了。所以没有入场效果，之所以有出场效果，是因为两张卡牌
                 匹配后，我们调用Color.clear或者Rectagle().opacity(0)让他消失了，相当于让卡牌出场了，所以有出场效果。
                 .transition(AnyTransition.asymmetric(insertion: .scale, removal: .opacity))

                 ***
                 给一个容器设置transition后，是这个容器整体的出场或入场。
                 给一个容器设置animation后，容器会将animation分发给所有的内部View，各自展示动画效果。
                 
                 最后这里修改了出入场动画，入场不要动画效果，因为入场的动画，由后续添加的matchGeometryEffect完成了。
                 */
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        // 让卡牌的翻转，加上动画效果
                        withAnimation{
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor(CardConstants.color)
    }
    
    var deckBody: some View{
        ZStack{
            ForEach(game.cards.filter(isUnDealt)){ card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNameSpace)
                /*
                 deck上卡牌的出入场动画，和游戏区(gameBody)的动画刚好相反，这样做的目的是，gameBody中opacity出场的卡牌，
                 在deck中以同样的opacity的方式入场，视觉观感上比较一致。
                 */
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
            }
        }
        // 闲置牌堆的deck，尺寸是固定的，不能让容器自动分配。
        .frame(width: CardConstants.unDealtWidth, height: CardConstants.unDealtHeigh)
        .foregroundColor(CardConstants.color)
        .onTapGesture{
            for card in game.cards{
                withAnimation(dealAnimation(for: card)){
                    deal(card)
                }
            }
        }
    }
        
    // 用于卡牌的常量
    private struct CardConstants{
        static let color = Color.red
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let unDealtHeigh: CGFloat = 90
        static let unDealtWidth: CGFloat = unDealtHeigh * aspectRatio
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
    
    var restart: some View{
        Button("Restart"){
            withAnimation{
                // 开始新游戏前需要将dealt清空。 
                dealt = []
                game.restart()
            }
        }
    }
}

// 卡牌View的封装
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

