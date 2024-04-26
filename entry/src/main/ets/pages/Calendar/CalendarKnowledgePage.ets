@Entry
@Component
struct CalendarKnowledgePage {
  build() {
    Navigation() {
      Text('内嵌 WebView 页面')
        .fontSize(20)
        .padding({ top: 100 })
    }
    .title('日历防诈骗须知')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}