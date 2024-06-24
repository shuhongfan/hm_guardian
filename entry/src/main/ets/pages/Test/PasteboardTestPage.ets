import { pasteboard } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct PasteboardTestPage {
  @State pasteText: string = ''

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
          Button('读取剪贴板-拼多多、淘宝等')
            .onClick(() => {
              // 1. 获取系统剪贴板
              const systemPasteboard = pasteboard.getSystemPasteboard()
              // 2. 读取剪贴板的数据(但是还不知道格式)
              //  踩坑：getDataSync 如果剪贴板为空，返回值为 undefined，undefined 不能提取内容会导致出错
              //  API 12: 需要配置 ohos.permission.READ_PASTEBOARD 权限后才能读取
              const pasteData = systemPasteboard.getDataSync()
              // 3. 提取内容(提取文本)
              this.pasteText = pasteData?.getPrimaryText() || ''
            })

          Text('剪贴板的文本:' + this.pasteText)
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