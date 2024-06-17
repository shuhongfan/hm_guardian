import { relationalStore } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct DatabaseTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('创建数据库文件')
            .onClick(async () => {
              // 创建数据库文件  getRdbStore
              await relationalStore.getRdbStore(getContext(), {
                name: 'heima2.db', // 数据库文件名
                securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全等级(跨端共享)
              })
              promptAction.showToast({ message: '数据库文件创建成功' })
            })

          Button('删除数据库文件')
            .onClick(async () => {
              // 删除数据库文件 deleteRdbStore
              await relationalStore.deleteRdbStore(getContext(), 'heima2.db')
              promptAction.showToast({ message: '数据库文件删除成功' })
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('关系型数据库')
    .titleMode(NavigationTitleMode.Mini)
  }
}