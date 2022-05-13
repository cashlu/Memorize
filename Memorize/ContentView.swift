//
//  ContentView.swift
//  Memorize
//
//  Created by 芦满 on 2022/4/16.
//

import SwiftUI

struct ContentView: View {
    /*
     语法说明：
     body是一个计算属性，类型约束"some View"代表get的返回值是一个遵循了View协议的类型。
     因为计算属性的get只有一个语句，所以可以省略return。

     这里不对viewModel赋值，而是在MemorizeApp.swift实例化ContentView的时候，将具体的参
     数传递进来。
     
     在viewModel前面@ObservedObject装饰器，目的是每次当viewObject发布有model发生变化的
     通知时，去接收这些通知，以便于反应到UI上。
     */
    @ObservedObject var viewModel: EmojiMemoryGame

    var body: some View {
        // 垂直布局
        VStack {
            // ScrollView包裹卡片列表区域，使其可以滚动，而不是遮挡下面的按钮。
            ScrollView {
                /*
                 stroke() 只绘制边框
                 fill() 填充颜色
                 stroke和fill切换，可以实现类似于牌面翻转的效果。

                 这里省略了参数content的label，因为利用了swift尾闭包的特性。

                 注意lazyVGrid的参数语法。列数的控制，传入的是GridItem对象的数组，
                 而不是简单的数字，之所以这样，是因为GridItem对象可以更精细的控制列
                 的属性。数组中放几个GridItem实例，则每行显示几个。

                 在本例中，只写了一个GridItem，但是在参数中指定了最小宽度和最大宽度。剩下的，
                 由SwiftUI自己来决定每行能放置多少个View。这样可以兼容横屏。
                 */
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))]) {
                    ForEach(viewModel.cards) { card in
                        CardView(card: card)
                            // 设置View的高宽比例
                            .aspectRatio(2 / 3, contentMode: .fit)
                            // 点击事件
                            .onTapGesture {
                                viewModel.choose(card)
                            }
                    }
                }.foregroundColor(/*@START_MENU_TOKEN@*/Color.red/*@END_MENU_TOKEN@*/)
            }
        }
        .padding(.horizontal)
        .font(.largeTitle)
    }
}

/// 卡片的封装
struct CardView: View {
    let card: MemoryGame<String>.Card
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 20)
            // 判断牌面是否翻转
            if card.isFaceUp {
                /*
                 在z轴上定义两个圆角矩形，下面的填充模式，前景白色。
                 上面的边框模式，前景红色。
                 这样做就可以较好的兼容白天模式和深夜模式。
                 */
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: 3)
                Text(card.content).font(.largeTitle)
                // 被找出匹配的图片，隐藏起来。
            }else if card.isMatched{
                shape.opacity(0)
            }else {
                shape.fill()
            }
        }
//        .onTapGesture {
//            isFaceUp = !isFaceUp
//        }
    }
}

// 右侧Preview相关的代码
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        ContentView(viewModel: game)
            .preferredColorScheme(.dark)
        ContentView(viewModel: game)
            .preferredColorScheme(.light)
    }
}
