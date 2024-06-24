import { contact } from '@kit.ContactsKit'
import { isEmulator } from '../../common/dev'
import { permissionManager } from '../../manager'

@Entry
@Component
struct ContactsTestPage {

  @State list: contact.Contact[] = []
  @State fullName: string = ''
  @State phoneNumber: string = ''
  @State isGrant: boolean = false

  aboutToAppear() {
    this.requestPermissions()
  }

  async requestPermissions() {
    // 申请通讯录权限
    this.isGrant = await permissionManager.requestPermissions([
      'ohos.permission.READ_CONTACTS',
      'ohos.permission.WRITE_CONTACTS',
    ])
    // 获取通讯录列表
    this.getList()
  }

  // 页面显示获取最新通讯录列表
  onPageShow() {
    this.getList()
  }

  // 模拟器没有通讯录，可以造一些假数据，让业务可以继续推进
  async getEmulatorContacts(): Promise<contact.Contact[]> {
    return [
      {
        phoneNumbers: [{ phoneNumber: "13111111" }],
        name: { fullName: "悟空" },
        key: "1",
        id: 1
      },
      {
        phoneNumbers: [{ phoneNumber: "2222" }],
        name: { fullName: "八戒" },
        key: "2",
        id: 2
      },
    ]
  }

  // 获取联系人列表
  async getList() {
    if (isEmulator()) {
      this.list = await this.getEmulatorContacts()
    } else {
      // 授权后，通过 queryContacts 不会弹出联系人选择的界面
      this.list = await contact.queryContacts(getContext())
    }
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('通过Picker的方式-无需授权')
            .onClick(async () => {
              // 通过Picker的方式，拉起联系人列表，引导用户完成界面操作
              // 简单业务推荐使用：该接口本身无需申请权限。(寄快递：选择收件人信息)
              if (isEmulator()) {
                // 如果是模拟器，返回假的数据
                this.list = await this.getEmulatorContacts()
              } else {
                // 如果是真机，获取真实的通讯录信息
                this.list = await contact.selectContacts()
              }
              const detail = this.list[0]
              if (detail) {
                this.fullName = detail.name?.fullName || ''
                this.phoneNumber = detail.phoneNumbers?.[0]?.phoneNumber || ''
              }
            })
          Text(JSON.stringify(this.list, null, 2))
          Text('联系人：' + this.fullName)
          Text('电话号码：' + this.phoneNumber)
          Divider()
            .strokeWidth(1)
          Text('是否授权通讯录访问权限：' + this.isGrant)
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