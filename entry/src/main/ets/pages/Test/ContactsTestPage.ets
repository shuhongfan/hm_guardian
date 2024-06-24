import { contact } from '@kit.ContactsKit'

@Entry
@Component
struct ContactsTestPage {

  @State list: contact.Contact[] = []
  @State fullName: string = ''
  @State phoneNumber: string = ''

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('通过Picker的方式-无需授权')
            .onClick(async () => {
              // 通过Picker的方式，拉起联系人列表，引导用户完成界面操作
              // 简单业务推荐使用：该接口本身无需申请权限。(寄快递：选择收件人信息)
              this.list = await contact.selectContacts()
              const detail = this.list[0]
              if (detail) {
                this.fullName = detail.name?.fullName || ''
                this.phoneNumber = detail.phoneNumbers?.[0]?.phoneNumber || ''
              }
            })
          Text(JSON.stringify(this.list, null, 2))
          Text('联系人：' + this.fullName)
          Text('电话号码：' + this.phoneNumber)
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