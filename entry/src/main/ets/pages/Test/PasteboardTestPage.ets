import { pasteboard } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct PasteboardTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('设置剪贴板-复制链接分享')
            .onClick(() => {
              // 1. 获取系统剪贴板
              const systemPasteboard = pasteboard.getSystemPasteboard()
              // 2. 创建待写入的数据(注意格式)
              const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, '剪贴板的测试数据')
              // 3. 把数据设置到剪贴板中
              systemPasteboard.setDataSync(pasteData)

              promptAction.showToast({ message: 'ok' })
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .titleMode(NavigationTitleMode.Mini)
  }
}