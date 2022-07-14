//
//  AspectVGrid.swift
//  Memorize
//
//  Created by 芦满 on 2022/7/11.



import SwiftUI

/*
 卡牌的显示布局，这里单独抽离出来，以便于日后实现复用。
 */
struct AspectVGrid<Item, ItemView>: View where ItemView: View, Item: Identifiable {
    var items: [Item]
    var aspectRatio: CGFloat
    /*
     这里使用了另一个泛型ItemView，而不是some View，因为some View代表
     当前函数返回某个遵循View协议的对象，但不确定是哪一个，具体在函数体中
     确认。而这里只是声明属性，并没有具体的函数实现，所以不能用在这里。
     下面的body可以用，是因为body有具体的函数实现。body会根据内部包含的具体
     View实现类，来替换声明中的some View。
     简单一句话概括：这是Swift的语法限制。
     
     但是，这里的ItemView也不是毫无限制，他必须是一个View实现类，所以必有在
     函数声明的位置使用where关键字约束。
     */
    var content: (Item) -> ItemView
    
    /*
     正常情况下，闭包会在宿主函数执行完之后跟着一起消亡。但是如果在宿主函数return后，闭包依旧没有执行完成（例如异步操作），
     或者闭包存储在全局变量、实例属性（本例），那么这个闭包被称之为“逃逸”，需要在函数参数声明的时候使用 @escaping 包装器修饰。
     
     本例中，init是初始化函数，对象创建后，init则return，但是传入的闭包content存储在self.content中，并没有随之消亡，所以
     是一个“逃逸的闭包”。
     
     content参数前面的 @ViewBuilder，表示这个content是一个ViewBuilder。 @ViewBuilder 的作用，是让闭包content可以提供
     多个子view。在本例中，EmojiMemoryGameView.swift中，实例化AspectVGrid的时候，闭包中实际上传入的不止一个CardView，
     还有Rectangle。
     */
    init(items: [Item], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item)->ItemView){
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                let width: CGFloat = widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio)
                /*
                 spacing参数，去掉卡牌垂直方向的间隔。
                 columns参数，需要的是GripItem对象数组，本来可以直接写这个对象，但是为了去掉GripItem之间水平方向的间隔，
                 用adaptiveGridItem()方法封装了一下，目的就是去掉spacing。
                 */
                LazyVGrid(columns: [adaptiveGridItem(width: width)], spacing: 0){
                    /*
                     实际在foreach循环中展示的，是多个自定义的CardView对象。
                     CardView实例化时，实际上是调用了init()函数，所以在声明
                     content属性的时候，类型约束是一个函数，与实际并不冲突。
                     */
                    ForEach(items){item in
                        content(item)
                            .aspectRatio(aspectRatio, contentMode: .fit)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
    
    /*
     去掉LazyVGrip中，columns参数的GripItem对象的间距。
     */
    private func adaptiveGridItem(width: CGFloat) -> GridItem{
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    /*
     根据卡牌的数量，来自动决定卡牌尺寸以适应屏幕大小。
     */
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat{
        var columnCount = 1
        var rowCount = itemCount
        repeat{
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeigh = itemWidth / itemAspectRatio
            if CGFloat(rowCount) * itemHeigh < size.height{
                break
            }
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        }while columnCount < itemCount
        
        if columnCount > itemCount{
            columnCount = itemCount
        }
        return floor(size.width / CGFloat(columnCount))
    }
}
